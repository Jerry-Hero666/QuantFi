// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package config

import (
	"time"

	"github.com/zeromicro/go-zero/rest"
)

type Config struct {
	rest.RestConf
	Mysql MysqlConfig
	Auth  AuthConfig
	Admin AdminConfig
	Eth   EthConfig
}

type MysqlConfig struct {
	DSN     string
	MaxIdle int `json:",default=5"`
	MaxOpen int `json:",default=10"`
}

type AuthConfig struct {
	AccessSecret string
	AccessExpire int64 `json:",default=7200"`
}

type AdminConfig struct {
	Wallets []string
}

type EthConfig struct {
	Enabled            bool
	RPC                string
	DistributorAddress string
	StartBlock         uint64
	PollInterval       time.Duration `json:",default=15s"`
}
