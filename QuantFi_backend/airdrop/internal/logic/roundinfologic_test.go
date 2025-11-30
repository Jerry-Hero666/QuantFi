package logic

import (
	"context"
	"strings"
	"testing"
	"time"

	"airdrop/internal/entity"
	"airdrop/internal/testutil"
	"airdrop/internal/types"
)

func TestRoundInfoLogic(t *testing.T) {
	svcCtx := testutil.NewTestServiceContext(t)
	round := entity.AirdropRound{
		Name:          "RoundX",
		MerkleRoot:    "0xaaa",
		TokenAddress:  "0xbb",
		ClaimDeadline: time.Now().Add(time.Hour),
		Status:        "active",
	}
	if err := svcCtx.DB.Create(&round).Error; err != nil {
		t.Fatalf("create round: %v", err)
	}
	user := entity.User{
		Wallet: strings.ToLower("0xabc0000000000000000000000000000000000000"),
	}
	if err := svcCtx.DB.Create(&user).Error; err != nil {
		t.Fatalf("create user: %v", err)
	}
	rp := entity.RoundPoint{
		RoundID: round.ID,
		UserID:  user.ID,
		Points:  1234,
	}
	if err := svcCtx.DB.Create(&rp).Error; err != nil {
		t.Fatalf("create round point: %v", err)
	}
	req := &types.RoundInfoRequest{
		RoundName: round.Name,
	}
	resp, err := NewRoundInfoLogic(context.Background(), svcCtx).RoundInfo(req)
	if err != nil {
		t.Fatalf("round info: %v", err)
	}
	if resp.Data.TotalPoints != rp.Points {
		t.Fatalf("expected points %d, got %d", rp.Points, resp.Data.TotalPoints)
	}
}
