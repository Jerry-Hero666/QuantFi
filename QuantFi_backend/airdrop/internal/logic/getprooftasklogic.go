// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package logic

import (
	"context"
	"errors"

	"airdrop/internal/authctx"
	"airdrop/internal/entity"
	"airdrop/internal/svc"
	"airdrop/internal/types"
	"airdrop/internal/util"

	"github.com/zeromicro/go-zero/core/logx"
	"gorm.io/gorm"
)

type GetProofTaskLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func NewGetProofTaskLogic(ctx context.Context, svcCtx *svc.ServiceContext) *GetProofTaskLogic {
	return &GetProofTaskLogic{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *GetProofTaskLogic) GetProofTask(req *types.ClaimProofRequest) (resp *types.ClaimProofResponse, err error) {
	if req == nil {
		return nil, errors.New("request required")
	}
	if req.RoundId <= 0 {
		return nil, errors.New("invalid round id")
	}

	claims, ok := authctx.FromContext(l.ctx)
	if !ok {
		return nil, errors.New("unauthorized")
	}

	roundID := uint64(req.RoundId)

	// Verify round exists and is active
	var round entity.AirdropRound
	if err := l.svcCtx.DB.WithContext(l.ctx).Where("id = ?", roundID).First(&round).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("round not found")
		}
		return nil, err
	}

	// Get user's round point
	var roundPoint entity.RoundPoint
	if err := l.svcCtx.DB.WithContext(l.ctx).Where("user_id = ? AND round_id = ?", claims.UID, roundID).First(&roundPoint).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("no allocation for user in this round")
		}
		return nil, err
	}

	// Get user's wallet address
	var user entity.User
	if err := l.svcCtx.DB.WithContext(l.ctx).Where("id = ?", claims.UID).First(&user).Error; err != nil {
		return nil, err
	}

	// Get all round points for this round to build merkle tree
	var allRoundPoints []entity.RoundPoint
	if err := l.svcCtx.DB.WithContext(l.ctx).Where("round_id = ?", roundID).Select("user_id, points").Find(&allRoundPoints).Error; err != nil {
		return nil, err
	}

	// Get all users for these round points
	userIDs := make([]uint64, len(allRoundPoints))
	for i, rp := range allRoundPoints {
		userIDs[i] = rp.UserID
	}

	var users []entity.User
	if err := l.svcCtx.DB.WithContext(l.ctx).Where("id IN ?", userIDs).Find(&users).Error; err != nil {
		return nil, err
	}

	// Create a map of user_id -> wallet
	userMap := make(map[uint64]string)
	for _, u := range users {
		userMap[u.ID] = u.Wallet
	}

	// Build merkle leaves
	leaves := make([]util.MerkleLeaf, 0, len(allRoundPoints))
	for _, rp := range allRoundPoints {
		wallet, exists := userMap[rp.UserID]
		if !exists {
			l.Logger.Errorf("user %d not found for round point", rp.UserID)
			continue
		}
		leaves = append(leaves, util.MerkleLeaf{
			RoundID: roundID,
			Wallet:  wallet,
			Amount:  rp.Points,
		})
	}

	// Generate merkle proof
	proof, err := util.GenerateProof(roundID, user.Wallet, roundPoint.Points, leaves)
	if err != nil {
		return nil, err
	}

	if proof == nil {
		return nil, errors.New("failed to generate proof")
	}

	return &types.ClaimProofResponse{
		BaseResp: types.BaseResp{
			Code: 0,
			Msg:  "success",
		},
		Data: types.ClaimProofData{
			RoundId: req.RoundId,
			Wallet:  user.Wallet,
			Amount:  roundPoint.Points,
			Proof:   proof,
		},
	}, nil
}
