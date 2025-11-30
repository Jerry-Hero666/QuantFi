package logic

import (
	"context"
	"strings"
	"testing"
	"time"

	"airdrop/internal/authctx"
	"airdrop/internal/entity"
	"airdrop/internal/security"
	"airdrop/internal/testutil"
	"airdrop/internal/types"
)

func TestGetProofTaskLogic(t *testing.T) {
	svcCtx := testutil.NewTestServiceContext(t)

	// Create test users
	user1 := entity.User{
		Wallet:        strings.ToLower("0x1110000000000000000000000000000000000000"),
		PointsBalance: 0,
		FrozenPoints:  500,
	}
	if err := svcCtx.DB.Create(&user1).Error; err != nil {
		t.Fatalf("create user1: %v", err)
	}

	user2 := entity.User{
		Wallet:        strings.ToLower("0x2220000000000000000000000000000000000000"),
		PointsBalance: 0,
		FrozenPoints:  300,
	}
	if err := svcCtx.DB.Create(&user2).Error; err != nil {
		t.Fatalf("create user2: %v", err)
	}

	// Create round
	round := entity.AirdropRound{
		Name:          "Round1",
		MerkleRoot:    "0xroot",
		TokenAddress:  "0xtoken",
		ClaimDeadline: time.Now().Add(time.Hour),
		Status:        "active",
	}
	if err := svcCtx.DB.Create(&round).Error; err != nil {
		t.Fatalf("create round: %v", err)
	}

	// Create round points
	rp1 := entity.RoundPoint{
		RoundID: round.ID,
		UserID:  user1.ID,
		Points:  500,
	}
	if err := svcCtx.DB.Create(&rp1).Error; err != nil {
		t.Fatalf("create round point 1: %v", err)
	}

	rp2 := entity.RoundPoint{
		RoundID: round.ID,
		UserID:  user2.ID,
		Points:  300,
	}
	if err := svcCtx.DB.Create(&rp2).Error; err != nil {
		t.Fatalf("create round point 2: %v", err)
	}

	// Test GetProofTask for user1
	ctx := authctx.WithClaims(context.Background(), &security.Claims{
		UID:    user1.ID,
		Wallet: user1.Wallet,
		Role:   security.RoleUser,
	})

	req := &types.ClaimProofRequest{
		RoundId: int64(round.ID),
	}

	resp, err := NewGetProofTaskLogic(ctx, svcCtx).GetProofTask(req)
	if err != nil {
		t.Fatalf("get proof task: %v", err)
	}

	// Verify response
	if resp.Code != 0 {
		t.Fatalf("expected code 0, got %d", resp.Code)
	}

	if resp.Data.RoundId != req.RoundId {
		t.Fatalf("expected round id %d, got %d", req.RoundId, resp.Data.RoundId)
	}

	if !strings.EqualFold(resp.Data.Wallet, user1.Wallet) {
		t.Fatalf("expected wallet %s, got %s", user1.Wallet, resp.Data.Wallet)
	}

	if resp.Data.Amount != rp1.Points {
		t.Fatalf("expected amount %d, got %d", rp1.Points, resp.Data.Amount)
	}

	if len(resp.Data.Proof) == 0 {
		t.Fatalf("expected non-empty proof, got empty")
	}

	// Test with invalid round id
	reqInvalid := &types.ClaimProofRequest{
		RoundId: 999,
	}
	_, err = NewGetProofTaskLogic(ctx, svcCtx).GetProofTask(reqInvalid)
	if err == nil {
		t.Fatalf("expected error for invalid round id")
	}

	// Test with user not in round
	user3 := entity.User{
		Wallet:        strings.ToLower("0x3330000000000000000000000000000000000000"),
		PointsBalance: 0,
		FrozenPoints:  0,
	}
	if err := svcCtx.DB.Create(&user3).Error; err != nil {
		t.Fatalf("create user3: %v", err)
	}

	ctx3 := authctx.WithClaims(context.Background(), &security.Claims{
		UID:    user3.ID,
		Wallet: user3.Wallet,
		Role:   security.RoleUser,
	})

	_, err = NewGetProofTaskLogic(ctx3, svcCtx).GetProofTask(req)
	if err == nil {
		t.Fatalf("expected error for user not in round")
	}
}

