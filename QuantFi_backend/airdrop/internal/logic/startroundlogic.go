// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package logic

import (
	"context"
	"errors"
	"math/big"
	"strings"
	"time"

	"airdrop/internal/entity"
	"airdrop/internal/svc"
	"airdrop/internal/types"
	"airdrop/internal/util"

	"airdrop/internal/contract"

	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/ethclient"
	"github.com/zeromicro/go-zero/core/logx"
	"gorm.io/gorm"
)

type StartRoundLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func NewStartRoundLogic(ctx context.Context, svcCtx *svc.ServiceContext) *StartRoundLogic {
	return &StartRoundLogic{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *StartRoundLogic) StartRound(req *types.StartRoundRequest) (*types.RoundInfoResponse, error) {
	if req == nil {
		return nil, errors.New("request required")
	}
	if strings.TrimSpace(req.RoundName) == "" {
		return nil, errors.New("round name required")
	}
	deadline := time.Unix(req.ClaimDeadline, 0)
	if deadline.Before(time.Now()) {
		return nil, errors.New("deadline must be in future")
	}
	round := &entity.AirdropRound{
		Name:          req.RoundName,
		MerkleRoot:    "", // 将在生成后更新
		TokenAddress:  strings.ToLower(req.TokenAddress),
		ClaimDeadline: deadline,
		Status:        "active",
	}

	now := time.Now().UTC()
	round.SnapshotAt = &now

	var merkleRoot string
	if err := l.svcCtx.RunTx(l.ctx, func(tx *gorm.DB) error {
		// 先创建 round 以获取 ID
		if err := tx.Create(round).Error; err != nil {
			return err
		}

		// Snapshot round in the same transaction
		var users []entity.User
		if err := tx.Find(&users).Error; err != nil {
			return err
		}

		// 收集用于生成 MerkleRoot 的数据
		var merkleLeaves []util.MerkleLeaf
		for i := range users {
			u := users[i]
			if u.PointsBalance == 0 {
				continue
			}

			// 创建 RoundPoint
			entry := entity.RoundPoint{
				RoundID: round.ID,
				UserID:  u.ID,
				Points:  u.PointsBalance,
			}
			if err := tx.Create(&entry).Error; err != nil {
				return err
			}

			// 收集 Merkle 叶子节点数据
			merkleLeaves = append(merkleLeaves, util.MerkleLeaf{
				RoundID: uint64(round.ID),
				Wallet:  strings.ToLower(u.Wallet),
				Amount:  u.PointsBalance,
			})

			u.FrozenPoints = u.PointsBalance
			u.PointsBalance = 0
			if err := tx.Save(&u).Error; err != nil {
				return err
			}
			ledger := &entity.PointsLedger{
				UserID: u.ID,
				Delta:  -entry.Points,
				Reason: "snapshot",
			}
			if err := tx.Create(ledger).Error; err != nil {
				return err
			}
		}

		if len(merkleLeaves) == 0 {
			return errors.New("no users with points")
		}

		// 生成 MerkleRoot
		root, _, err := util.BuildMerkleTree(merkleLeaves)
		if err != nil {
			return err
		}
		merkleRoot = common.BytesToHash(root).Hex()
		round.MerkleRoot = strings.ToLower(merkleRoot)

		// 更新 round 的 MerkleRoot
		if err := tx.Model(round).Update("merkle_root", round.MerkleRoot).Error; err != nil {
			return err
		}
		// 调用合约开启新的 round
		l.ContractStartRound(round)
		return nil
	}); err != nil {
		return nil, err
	}

	var total int64
	l.svcCtx.DB.WithContext(l.ctx).Model(&entity.RoundPoint{}).Where("round_id = ?", round.ID).Select("COALESCE(SUM(points),0)").Scan(&total)

	return &types.RoundInfoResponse{
		BaseResp: types.BaseResp{
			Code: 0,
			Msg:  "success",
		},
		Data: types.RoundInfoData{
			CurrentRoundId: int64(round.ID),
			RoundName:      round.Name,
			ClaimDeadline:  round.ClaimDeadline.Unix(),
			MerkleRoot:     round.MerkleRoot,
			TokenAddress:   round.TokenAddress,
			TotalPoints:    total,
		},
	}, nil
}

const (
	// 交易等待超时时间
	transactionTimeout = 5 * time.Minute
	// 默认Gas Limit（可配置化）
	defaultGasLimit = uint64(300000)
)

func (l *StartRoundLogic) ContractStartRound(round *entity.AirdropRound) error {
	distributorAddress := common.HexToAddress(l.svcCtx.Config.Eth.DistributorAddress)

	// 创建带超时的上下文
	ctx, cancel := context.WithTimeout(context.Background(), transactionTimeout)
	defer cancel()

	client, err := ethclient.Dial(l.svcCtx.Config.Eth.RPC)
	if err != nil {
		return err
	}
	defer client.Close()

	contractInstance, err := contract.NewContract(distributorAddress, client)
	if err != nil {
		return err
	}

	// 准备调用合约所需的参数
	roundID := big.NewInt(int64(round.ID))
	merkleRoot := common.HexToHash(round.MerkleRoot)
	deadline := uint64(round.ClaimDeadline.Unix())
	chainId := big.NewInt(int64(l.svcCtx.Config.Eth.ChainID))
	// 获取私钥用于签名交易
	privateKey, err := crypto.HexToECDSA(l.svcCtx.Config.Eth.OwnerPrivateKey)
	if err != nil {
		return err
	}

	// 创建交易选项
	auth, err := bind.NewKeyedTransactorWithChainID(privateKey, chainId)
	if err != nil {
		return err
	}

	// 设置合理的gas限制和gas价格
	auth.GasLimit = l.svcCtx.Config.Eth.GasLimit
	if auth.GasLimit == 0 {
		auth.GasLimit = defaultGasLimit
	}
	if l.svcCtx.Config.Eth.GasPrice != 0 {
		auth.GasPrice = big.NewInt(int64(l.svcCtx.Config.Eth.GasPrice))
	} else {
		auth.GasPrice, err = client.SuggestGasPrice(ctx)
		if err != nil {
			return err
		}
	}

	// 调用合约的 StartRound 方法
	tx, err := contractInstance.StartRound(auth, roundID, merkleRoot, deadline)
	if err != nil {
		return err
	}

	l.Logger.Infof("StartRound transaction sent: %s", tx.Hash().Hex())

	// 等待交易确认
	receipt, err := bind.WaitMined(ctx, client, tx)
	if err != nil {
		return err
	}

	if receipt.Status != 1 {
		return errors.New("transaction failed")
	}

	l.Logger.Infof("StartRound transaction confirmed in block: %d", receipt.BlockNumber.Uint64())

	return nil
}
