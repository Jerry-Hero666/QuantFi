// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package logic

import (
	"context"
	"errors"
	"time"

	"airdrop/internal/entity"
	"airdrop/internal/security"
	"airdrop/internal/svc"
	"airdrop/internal/types"
	"airdrop/internal/util"

	"airdrop/internal/tasks/handler"

	"github.com/zeromicro/go-zero/core/logx"
	"gorm.io/gorm"
)

const loginMessagePrefix = "airdrop-login"
const loginSkew = 5 * time.Minute

type LoginLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func NewLoginLogic(ctx context.Context, svcCtx *svc.ServiceContext) *LoginLogic {
	return &LoginLogic{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *LoginLogic) Login(req *types.LoginRequest) (*types.LoginResponse, error) {
	if req == nil {
		return nil, errors.New("request required")
	}
	wallet, err := util.NormalizeWallet(req.Wallet)
	if err != nil {
		return nil, err
	}
	if !l.validateTimestamp(req.Timestamp) {
		return nil, errors.New("timestamp skew too large")
	}
	// message := fmt.Sprintf("%s:%s:%d", loginMessagePrefix, wallet, req.Timestamp)
	// if err := util.VerifyPersonalSignature(wallet, req.Signature, message); err != nil {
	// 	return nil, err
	// }

	var user entity.User
	if err := l.svcCtx.DB.Where("wallet = ?", wallet).First(&user).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			user = entity.User{
				Wallet:      wallet,
				LoginStreak: 0,
				LoginDays:   0,
			}
			if err = l.svcCtx.DB.Create(&user).Error; err != nil {
				return nil, err
			}
		} else {
			return nil, err
		}
	}

	role := security.RoleUser
	if l.svcCtx.IsAdminWallet(wallet) {
		role = security.RoleAdmin
	}
	token, expiresAt, err := l.svcCtx.JWTManager.Generate(user.ID, wallet, role)
	if err != nil {
		return nil, err
	}

	if taskHandler, err := handler.NewTaskHandler(&handler.TaskHandlerParams{
		Ctx:    l.ctx,
		SvcCtx: l.svcCtx,
		SubmitTask: &types.SubmitTaskRequest{
			TaskCode: handler.LoginTaskCode,
			Wallet:   wallet,
		},
	}); err == nil {
		if err := taskHandler.Handle(); err != nil {
			l.Logger.Errorf("handle task failed: %v", err)
		}
	} else {
		l.Logger.Errorf("new task handler failed: %v", err)
	}

	if err := l.svcCtx.DB.Where("wallet = ?", wallet).First(&user).Error; err != nil {
		return nil, err
	}

	return &types.LoginResponse{
		BaseResp: types.BaseResp{
			Code: 0,
			Msg:  "success",
		},
		Data: types.LoginData{
			AccessToken: token,
			ExpiresAt:   expiresAt,
			LoginDays:   int64(user.LoginDays),
			Points:      user.PointsBalance,
		},
	}, nil
}

func (l *LoginLogic) validateTimestamp(ts int64) bool {
	if ts == 0 {
		return false
	}
	t := time.Unix(ts, 0)
	diff := time.Since(t)
	if diff < 0 {
		diff = -diff
	}
	return diff <= loginSkew
}
