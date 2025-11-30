package logic

import (
	"context"
	"strings"
	"testing"
	"time"

	"airdrop/internal/entity"
	"airdrop/internal/testutil"
	"airdrop/internal/types"
	"airdrop/internal/util"

	"github.com/ethereum/go-ethereum/common"
)

func TestStartRoundLogic(t *testing.T) {
	svcCtx := testutil.NewTestServiceContext(t)
	user := entity.User{
		Wallet:        strings.ToLower("0x1230000000000000000000000000000000000001"),
		PointsBalance: 800,
	}
	if err := svcCtx.DB.Create(&user).Error; err != nil {
		t.Fatalf("create user: %v", err)
	}
	req := &types.StartRoundRequest{
		RoundName:     "Genesis",
		MerkleRoot:    "", // MerkleRoot 现在会自动生成
		TokenAddress:  "0xdef",
		ClaimDeadline: time.Now().Add(1 * time.Hour).Unix(),
	}
	resp, err := NewStartRoundLogic(context.Background(), svcCtx).StartRound(req)
	if err != nil {
		t.Fatalf("start round: %v", err)
	}
	if resp.Data.CurrentRoundId == 0 {
		t.Fatal("round id missing")
	}

	// 验证 MerkleRoot 已生成
	if resp.Data.MerkleRoot == "" {
		t.Fatal("merkle root should be generated")
	}
	if !strings.HasPrefix(resp.Data.MerkleRoot, "0x") {
		t.Fatalf("merkle root should start with 0x, got %s", resp.Data.MerkleRoot)
	}
	if len(resp.Data.MerkleRoot) != 66 { // 0x + 64 hex chars
		t.Fatalf("merkle root should be 66 chars (0x + 64 hex), got %d: %s", len(resp.Data.MerkleRoot), resp.Data.MerkleRoot)
	}
	t.Logf("merkle root: %s", resp.Data.MerkleRoot)

	// 验证 MerkleRoot 与手动计算的一致
	var round entity.AirdropRound
	if err := svcCtx.DB.First(&round, resp.Data.CurrentRoundId).Error; err != nil {
		t.Fatalf("load round: %v", err)
	}

	// 手动计算 MerkleRoot 进行验证
	leaves := []util.MerkleLeaf{
		{
			RoundID: uint64(round.ID),
			Wallet:  strings.ToLower(user.Wallet),
			Amount:  800,
		},
	}
	expectedRoot, _, err := util.BuildMerkleTree(leaves)
	if err != nil {
		t.Fatalf("build merkle tree: %v", err)
	}
	expectedRootHex := strings.ToLower(common.BytesToHash(expectedRoot).Hex())
	if resp.Data.MerkleRoot != expectedRootHex {
		t.Fatalf("merkle root mismatch: expected %s, got %s", expectedRootHex, resp.Data.MerkleRoot)
	}

	var snapshot entity.RoundPoint
	if err := svcCtx.DB.Where("round_id = ? AND user_id = ?", resp.Data.CurrentRoundId, user.ID).First(&snapshot).Error; err != nil {
		t.Fatalf("round snapshot missing: %v", err)
	}
	if snapshot.Points != 800 {
		t.Fatalf("expected snapshot 800, got %d", snapshot.Points)
	}
	if err := svcCtx.DB.First(&user, user.ID).Error; err != nil {
		t.Fatalf("reload user: %v", err)
	}
	if user.PointsBalance != 0 {
		t.Fatalf("expected user points zero after snapshot, got %d", user.PointsBalance)
	}
}

func TestStartRoundLogic_MultipleUsers(t *testing.T) {
	svcCtx := testutil.NewTestServiceContext(t)

	// 创建多个用户
	users := []entity.User{
		{
			Wallet:        strings.ToLower("0x1110000000000000000000000000000000000001"),
			PointsBalance: 1000,
		},
		{
			Wallet:        strings.ToLower("0x2220000000000000000000000000000000000002"),
			PointsBalance: 2000,
		},
		{
			Wallet:        strings.ToLower("0x3330000000000000000000000000000000000003"),
			PointsBalance: 1500,
		},
	}
	for i := range users {
		if err := svcCtx.DB.Create(&users[i]).Error; err != nil {
			t.Fatalf("create user %d: %v", i, err)
		}
	}

	req := &types.StartRoundRequest{
		RoundName:     "MultiUserRound",
		MerkleRoot:    "",
		TokenAddress:  "0xtoken",
		ClaimDeadline: time.Now().Add(1 * time.Hour).Unix(),
	}
	resp, err := NewStartRoundLogic(context.Background(), svcCtx).StartRound(req)
	if err != nil {
		t.Fatalf("start round: %v", err)
	}

	// 验证 MerkleRoot 已生成
	if resp.Data.MerkleRoot == "" {
		t.Fatal("merkle root should be generated")
	}

	// 验证 MerkleRoot 与手动计算的一致
	var round entity.AirdropRound
	if err := svcCtx.DB.First(&round, resp.Data.CurrentRoundId).Error; err != nil {
		t.Fatalf("load round: %v", err)
	}

	// 手动计算 MerkleRoot
	leaves := []util.MerkleLeaf{
		{
			RoundID: uint64(round.ID),
			Wallet:  strings.ToLower(users[0].Wallet),
			Amount:  1000,
		},
		{
			RoundID: uint64(round.ID),
			Wallet:  strings.ToLower(users[1].Wallet),
			Amount:  2000,
		},
		{
			RoundID: uint64(round.ID),
			Wallet:  strings.ToLower(users[2].Wallet),
			Amount:  1500,
		},
	}
	expectedRoot, _, err := util.BuildMerkleTree(leaves)
	if err != nil {
		t.Fatalf("build merkle tree: %v", err)
	}
	expectedRootHex := strings.ToLower(common.BytesToHash(expectedRoot).Hex())
	if resp.Data.MerkleRoot != expectedRootHex {
		t.Fatalf("merkle root mismatch: expected %s, got %s", expectedRootHex, resp.Data.MerkleRoot)
	}

	// 验证总积分
	if resp.Data.TotalPoints != 4500 {
		t.Fatalf("expected total points 4500, got %d", resp.Data.TotalPoints)
	}
}

func TestStartRoundLogic_NoUsers(t *testing.T) {
	svcCtx := testutil.NewTestServiceContext(t)

	req := &types.StartRoundRequest{
		RoundName:     "EmptyRound",
		MerkleRoot:    "",
		TokenAddress:  "0xtoken",
		ClaimDeadline: time.Now().Add(1 * time.Hour).Unix(),
	}
	resp, err := NewStartRoundLogic(context.Background(), svcCtx).StartRound(req)
	if err != nil {
		t.Fatalf("start round: %v", err)
	}

	// 验证空 MerkleRoot
	expectedEmptyRoot := "0x0000000000000000000000000000000000000000000000000000000000000000"
	if resp.Data.MerkleRoot != expectedEmptyRoot {
		t.Fatalf("expected empty merkle root %s, got %s", expectedEmptyRoot, resp.Data.MerkleRoot)
	}

	if resp.Data.TotalPoints != 0 {
		t.Fatalf("expected total points 0, got %d", resp.Data.TotalPoints)
	}
}
