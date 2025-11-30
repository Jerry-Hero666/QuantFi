package logic

import (
	"context"
	"fmt"
	"strings"
	"testing"
	"time"

	"airdrop/internal/testutil"
	"airdrop/internal/types"

	"github.com/ethereum/go-ethereum/accounts"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/common/hexutil"
	"github.com/ethereum/go-ethereum/crypto"
)

func TestLoginLogic(t *testing.T) {
	svcCtx := testutil.NewTestServiceContext(t)
	priv, err := crypto.GenerateKey()
	if err != nil {
		t.Fatalf("generate key: %v", err)
	}
	wallet := crypto.PubkeyToAddress(priv.PublicKey).Hex()
	normalized := strings.ToLower(common.HexToAddress(wallet).Hex())
	ts := time.Now().Unix()
	message := fmt.Sprintf("%s:%s:%d", loginMessagePrefix, normalized, ts)
	hash := accounts.TextHash([]byte(message))
	sig, err := crypto.Sign(hash, priv)
	if err != nil {
		t.Fatalf("sign: %v", err)
	}
	sig[64] += 27
	req := &types.LoginRequest{
		Wallet:    wallet,
		Signature: hexutil.Encode(sig),
		Timestamp: ts,
	}
	resp, err := NewLoginLogic(context.Background(), svcCtx).Login(req)
	if err != nil {
		t.Fatalf("login failed: %v", err)
	}
	if resp.Data.AccessToken == "" {
		t.Fatal("token empty")
	}
	if resp.Data.Points != 100 {
		t.Fatalf("expected 100 points, got %d", resp.Data.Points)
	}
}
