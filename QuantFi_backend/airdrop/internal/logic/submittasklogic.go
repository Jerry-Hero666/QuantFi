// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package logic

import (
	"context"

	"airdrop/internal/svc"
	"airdrop/internal/types"

	"airdrop/internal/tasks/handler"

	"github.com/zeromicro/go-zero/core/logx"
)

type SubmitTaskLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func NewSubmitTaskLogic(ctx context.Context, svcCtx *svc.ServiceContext) *SubmitTaskLogic {
	return &SubmitTaskLogic{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *SubmitTaskLogic) SubmitTask(req *types.SubmitTaskRequest) (resp *types.SubmitTaskResponse, err error) {
	taskHandler, err := handler.NewTaskHandler(&handler.TaskHandlerParams{
		SubmitTask: req,
		Ctx:        l.ctx,
		SvcCtx:     l.svcCtx,
	})
	if err != nil {
		return nil, err
	}
	err = taskHandler.Handle()
	if err != nil {
		return nil, err
	}
	return &types.SubmitTaskResponse{
		BaseResp: types.BaseResp{Code: 0, Msg: "success"},
	}, nil
}
