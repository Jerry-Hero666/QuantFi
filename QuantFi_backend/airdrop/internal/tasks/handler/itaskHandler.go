package handler

import (
	"airdrop/internal/svc"
	"airdrop/internal/types"
	"context"
	"fmt"
)

const (
	InvestTaskCode = "INVEST"
	LoginTaskCode  = "LOGIN"
)

type TaskHandlerParams struct {
	SubmitTask *types.SubmitTaskRequest
	Ctx        context.Context
	SvcCtx     *svc.ServiceContext
}

func NewTaskHandler(params *TaskHandlerParams) (ITaskHandler, error) {
	switch params.SubmitTask.TaskCode {
	case LoginTaskCode:
		return &LoginTaskHandler{params: params}, nil
	case InvestTaskCode:
		return &InvestTaskHandler{params: params}, nil
	default:
		return nil, fmt.Errorf("unknown task code: %s", params.SubmitTask.TaskCode)
	}
}

type ITaskHandler interface {
	Handle() error
}
