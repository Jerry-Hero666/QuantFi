package listener

import (
	"context"
	"errors"
	"math/big"
	"strings"
	"time"

	"airdrop/internal/config"
	"airdrop/internal/entity"

	geth "github.com/ethereum/go-ethereum"
	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/ethclient"
	"github.com/zeromicro/go-zero/core/logx"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

const distributorABI = `[
  {"anonymous":false,"inputs":[{"indexed":true,"internalType":"uint256","name":"roundId","type":"uint256"},{"indexed":true,"internalType":"address","name":"account","type":"address"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"},{"indexed":false,"internalType":"bytes32","name":"leaf","type":"bytes32"}],"name":"Claimed","type":"event"},
  {"anonymous":false,"inputs":[{"indexed":true,"internalType":"uint256","name":"roundId","type":"uint256"},{"indexed":false,"internalType":"bytes32","name":"merkleRoot","type":"bytes32"},{"indexed":false,"internalType":"uint64","name":"deadline","type":"uint64"}],"name":"RoundStarted","type":"event"}
]`

type ClaimWatcher struct {
	ctx    context.Context
	cancel context.CancelFunc
	cfg    config.EthConfig
	db     *gorm.DB
	abi    abi.ABI
	logger logx.Logger
}

func NewClaimWatcher(ctx context.Context, cfg config.EthConfig, db *gorm.DB) (*ClaimWatcher, error) {
	parsed, err := abi.JSON(strings.NewReader(distributorABI))
	if err != nil {
		return nil, err
	}
	subCtx, cancel := context.WithCancel(ctx)
	return &ClaimWatcher{
		ctx:    subCtx,
		cancel: cancel,
		cfg:    cfg,
		db:     db,
		abi:    parsed,
		logger: logx.WithContext(ctx),
	}, nil
}

func (c *ClaimWatcher) Run() {
	if !c.cfg.Enabled || c.cfg.RPC == "" {
		c.logger.Infof("claim watcher disabled")
		return
	}
	for {
		if c.ctx.Err() != nil {
			return
		}
		client, err := ethclient.DialContext(c.ctx, c.cfg.RPC)
		if err != nil {
			c.logger.Errorf("dial eth: %v", err)
			time.Sleep(c.cfg.PollInterval)
			continue
		}
		if err := c.consume(client); err != nil {
			c.logger.Errorf("claim watcher error: %v", err)
			time.Sleep(c.cfg.PollInterval)
		}
		client.Close()
	}
}

func (c *ClaimWatcher) consume(client *ethclient.Client) error {
	logsCh := make(chan types.Log)
	query := geth.FilterQuery{
		FromBlock: big.NewInt(int64(c.cfg.StartBlock)),
		Addresses: []common.Address{common.HexToAddress(c.cfg.DistributorAddress)},
		Topics:    [][]common.Hash{{c.abi.Events["Claimed"].ID}},
	}
	sub, err := client.SubscribeFilterLogs(c.ctx, query, logsCh)
	if err != nil {
		return err
	}
	defer sub.Unsubscribe()
	for {
		select {
		case <-c.ctx.Done():
			return nil
		case err := <-sub.Err():
			return err
		case log := <-logsCh:
			if err := c.handleLog(log); err != nil {
				c.logger.Errorf("handle claim log: %v", err)
			}
		}
	}
}

func (c *ClaimWatcher) handleLog(event types.Log) error {
	if len(event.Topics) < 3 {
		return nil
	}
	roundID := new(big.Int).SetBytes(event.Topics[1].Bytes()).Uint64()
	account := strings.ToLower(common.BytesToAddress(event.Topics[2].Bytes()).Hex())

	var data struct {
		Amount *big.Int
		Leaf   [32]byte
	}
	if err := c.abi.UnpackIntoInterface(&data, "Claimed", event.Data); err != nil {
		return err
	}
	amount := data.Amount.Int64()
	return c.db.WithContext(c.ctx).Transaction(func(tx *gorm.DB) error {
		var user entity.User
		if err := tx.Where("wallet = ?", account).First(&user).Error; err != nil {
			return err
		}
		var snapshot entity.RoundPoint
		if err := tx.Clauses(clause.Locking{Strength: "UPDATE"}).Where("round_id = ? AND user_id = ?", roundID, user.ID).First(&snapshot).Error; err != nil {
			return err
		}
		if snapshot.Points-snapshot.ClaimedPoints < amount {
			return errors.New("insufficient snapshot balance")
		}
		snapshot.ClaimedPoints += amount
		if err := tx.Save(&snapshot).Error; err != nil {
			return err
		}
		updates := map[string]interface{}{
			"status":     entity.ClaimStatusCompleted,
			"tx_hash":    event.TxHash.Hex(),
			"claimed_at": time.Now().UTC(),
		}
		if err := tx.Model(&entity.Claim{}).Where("round_id = ? AND wallet = ?", roundID, account).Updates(updates).Error; err != nil {
			if err == gorm.ErrRecordNotFound {
				claim := entity.Claim{
					RoundID: roundID,
					UserID:  user.ID,
					Wallet:  account,
					Amount:  amount,
					TxHash:  event.TxHash.Hex(),
					Status:  entity.ClaimStatusCompleted,
				}
				if err := tx.Create(&claim).Error; err != nil {
					return err
				}
			} else {
				return err
			}
		}
		if user.FrozenPoints >= amount {
			user.FrozenPoints -= amount
		} else {
			user.FrozenPoints = 0
		}
		return tx.Save(&user).Error
	})
}

func (c *ClaimWatcher) Stop() {
	if c.cancel != nil {
		c.cancel()
	}
}
