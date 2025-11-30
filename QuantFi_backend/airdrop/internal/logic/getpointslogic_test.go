package logic

import (
	"context"
	"strings"
	"testing"

	"airdrop/internal/authctx"
	"airdrop/internal/entity"
	"airdrop/internal/security"
	"airdrop/internal/testutil"

	"github.com/ethereum/go-ethereum/common"
)

func TestGetPointsLogic(t *testing.T) {
	svcCtx := testutil.NewTestServiceContext(t)
	wallet := common.HexToAddress("0x1234").Hex()
	user := entity.User{
		Wallet:        strings.ToLower(wallet),
		PointsBalance: 2000,
		FrozenPoints:  500,
		LoginStreak:   3,
	}
	if err := svcCtx.DB.Create(&user).Error; err != nil {
		t.Fatalf("create user: %v", err)
	}
	rp := entity.RoundPoint{
		RoundID: 1,
		UserID:  user.ID,
		Points:  500,
	}
	if err := svcCtx.DB.Create(&rp).Error; err != nil {
		t.Fatalf("create round point: %v", err)
	}
	claims := &security.Claims{UID: user.ID, Wallet: user.Wallet}
	ctx := authctx.WithClaims(context.Background(), claims)
	resp, err := NewGetPointsLogic(ctx, svcCtx).GetPoints()
	if err != nil {
		t.Fatalf("get points: %v", err)
	}
	if resp.Data.Available != user.PointsBalance {
		t.Fatalf("expected available %d, got %d", user.PointsBalance, resp.Data.Available)
	}
	if resp.Data.LatestRound != int64(rp.RoundID) {
		t.Fatalf("expected latest round %d, got %d", rp.RoundID, resp.Data.LatestRound)
	}
}
