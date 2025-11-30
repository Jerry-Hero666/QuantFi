// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package logic

import (
	"context"

	"airdrop/internal/entity"
	"airdrop/internal/svc"
	"airdrop/internal/types"

	"errors"

	"github.com/zeromicro/go-zero/core/logx"
	"gorm.io/gorm"
)

type RoundInfoLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func NewRoundInfoLogic(ctx context.Context, svcCtx *svc.ServiceContext) *RoundInfoLogic {
	return &RoundInfoLogic{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *RoundInfoLogic) RoundInfo(req *types.RoundInfoRequest) (*types.RoundInfoResponse, error) {
	if req.RoundId == 0 && req.RoundName == "" {
		return nil, errors.New("roundId and roundName cannot be empty")
	}
	var round entity.AirdropRound
	if req.RoundId != 0 {
		err := l.svcCtx.DB.WithContext(l.ctx).Where("id = ?", req.RoundId).First(&round).Error
		if err == gorm.ErrRecordNotFound {
			return &types.RoundInfoResponse{
				BaseResp: types.BaseResp{
					Code: 0,
					Msg:  "success",
				},
				Data: types.RoundInfoData{},
			}, nil
		}
	} else {
		err := l.svcCtx.DB.WithContext(l.ctx).Where("name like ?", "%"+req.RoundName+"%").Order("id DESC").First(&round).Error
		if err == gorm.ErrRecordNotFound {
			return &types.RoundInfoResponse{
				BaseResp: types.BaseResp{
					Code: 0,
					Msg:  "success",
				},
				Data: types.RoundInfoData{},
			}, nil
		}
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
