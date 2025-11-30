// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package svc

import (
	"context"
	"net/http"
	"strings"
	"time"

	"airdrop/internal/config"
	"airdrop/internal/listener"
	"airdrop/internal/middleware"
	"airdrop/internal/security"
	"airdrop/internal/util"

	"github.com/zeromicro/go-zero/core/logx"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

type ServiceContext struct {
	Config          config.Config
	DB              *gorm.DB
	JWTManager      *security.JwtManager
	JWTMiddleware   func(next http.HandlerFunc) http.HandlerFunc
	AdminMiddleware func(next http.HandlerFunc) http.HandlerFunc

	adminWallets map[string]struct{}
	claimWatcher *listener.ClaimWatcher
	cancelFn     context.CancelFunc
}

func NewServiceContext(c config.Config) *ServiceContext {
	return newServiceContext(c, nil)
}

func NewServiceContextWithDB(c config.Config, db *gorm.DB) *ServiceContext {
	return newServiceContext(c, db)
}

func newServiceContext(c config.Config, db *gorm.DB) *ServiceContext {
	if db == nil {
		db = mustInitDB(c.Mysql)
	}
	jwtMgr := security.NewJwtManager(c.Auth.AccessSecret, time.Duration(c.Auth.AccessExpire)*time.Second)
	adminSet := make(map[string]struct{})
	for _, w := range c.Admin.Wallets {
		normalized, err := util.NormalizeWallet(w)
		if err != nil {
			logx.Errorf("invalid admin wallet %s: %v", w, err)
			continue
		}
		adminSet[normalized] = struct{}{}
	}

	jwtMiddleware := middleware.NewJWTMiddleware(jwtMgr)
	adminMiddleware := middleware.NewAdminMiddleware()

	s := &ServiceContext{
		Config:          c,
		DB:              db,
		JWTManager:      jwtMgr,
		JWTMiddleware:   jwtMiddleware.Handle,
		AdminMiddleware: adminMiddleware.Handle,
		adminWallets:    adminSet,
	}
	return s
}

func mustInitDB(cfg config.MysqlConfig) *gorm.DB {
	gormCfg := &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	}
	db, err := gorm.Open(mysql.Open(cfg.DSN), gormCfg)
	if err != nil {
		logx.Errorf("failed to connect mysql: %v", err)
		panic(err)
	}
	sqlDB, err := db.DB()
	if err == nil {
		if cfg.MaxIdle > 0 {
			sqlDB.SetMaxIdleConns(cfg.MaxIdle)
		}
		if cfg.MaxOpen > 0 {
			sqlDB.SetMaxOpenConns(cfg.MaxOpen)
		}
		sqlDB.SetConnMaxLifetime(5 * time.Minute)
	}
	return db
}

func (s *ServiceContext) Start(ctx context.Context) {
	if s.cancelFn != nil {
		return
	}
	ctx, cancel := context.WithCancel(ctx)
	s.cancelFn = cancel

	if s.Config.Eth.Enabled {
		watcher, err := listener.NewClaimWatcher(ctx, s.Config.Eth, s.DB)
		if err != nil {
			logx.Errorf("failed to init claim watcher: %v", err)
		} else {
			s.claimWatcher = watcher
			go watcher.Run()
		}
	}
}

func (s *ServiceContext) Stop() {
	if s.cancelFn != nil {
		s.cancelFn()
	}
	if s.claimWatcher != nil {
		s.claimWatcher.Stop()
	}
}

func (s *ServiceContext) IsAdminWallet(wallet string) bool {
	_, ok := s.adminWallets[strings.ToLower(wallet)]
	return ok
}
