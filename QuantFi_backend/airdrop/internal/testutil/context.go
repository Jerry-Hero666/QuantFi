package testutil

import (
	"testing"
	"time"

	"airdrop/internal/config"
	"airdrop/internal/entity"
	"airdrop/internal/svc"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

const (
	TestAdminWallet = "0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
)

func NewTestServiceContext(t *testing.T) *svc.ServiceContext {
	t.Helper()
	db, err := gorm.Open(sqlite.Open("file::memory:?cache=shared"), &gorm.Config{})
	if err != nil {
		t.Fatalf("open sqlite: %v", err)
	}
	if err := db.AutoMigrate(
		&entity.User{},
		&entity.Task{},
		&entity.UserTask{},
		&entity.PointsLedger{},
		&entity.AirdropRound{},
		&entity.RoundPoint{},
		&entity.Claim{},
	); err != nil {
		t.Fatalf("auto migrate: %v", err)
	}
	cfg := config.Config{
		Auth: config.AuthConfig{
			AccessSecret: "test-secret",
			AccessExpire: int64((time.Hour).Seconds()),
		},
		Admin: config.AdminConfig{
			Wallets: []string{TestAdminWallet},
		},
	}
	return svc.NewServiceContextWithDB(cfg, db)
}
