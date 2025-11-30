// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package logic

import (
	"context"

	"airdrop/internal/authctx"
	"airdrop/internal/entity"
	"airdrop/internal/svc"
	"airdrop/internal/types"

	"github.com/zeromicro/go-zero/core/logx"
	"gorm.io/gorm"
)

type GetPointsLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func NewGetPointsLogic(ctx context.Context, svcCtx *svc.ServiceContext) *GetPointsLogic {
	return &GetPointsLogic{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *GetPointsLogic) GetPoints() (*types.PointsResponse, error) {
	claims, ok := authctx.FromContext(l.ctx)
	if !ok {
		return nil, gorm.ErrInvalidTransaction
	}
	var user entity.User
	if err := l.svcCtx.DB.WithContext(l.ctx).Where("id = ?", claims.UID).First(&user).Error; err != nil {
		return nil, err
	}
	var roundPoint entity.RoundPoint
	var latestRoundID int64
	if err := l.svcCtx.DB.WithContext(l.ctx).
		Where("user_id = ?", user.ID).
		Order("round_id DESC").
		First(&roundPoint).Error; err == nil {
		latestRoundID = int64(roundPoint.RoundID)
	}
	return &types.PointsResponse{
		BaseResp: types.BaseResp{
			Code: 0,
			Msg:  "success",
		},
		Data: types.PointsData{
			Wallet:      claims.Wallet,
			Available:   user.PointsBalance,
			Frozen:      user.FrozenPoints,
			LatestRound: latestRoundID,
			LoginStreak: int64(user.LoginStreak),
		},
	}, nil
}
