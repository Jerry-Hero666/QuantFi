package svc

import "github.com/zeromicro/go-zero/rest"

type ServiceContext struct {
    Config rest.Config
}

func NewServiceContext(c rest.Config) *ServiceContext {
    return &ServiceContext{
        Config: c,
    }
}


