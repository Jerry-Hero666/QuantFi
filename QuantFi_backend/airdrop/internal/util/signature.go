package util

import (
	"errors"
	"fmt"
	"strings"

	"github.com/ethereum/go-ethereum/accounts"
	"github.com/ethereum/go-ethereum/common/hexutil"
	"github.com/ethereum/go-ethereum/crypto"
)

var (
	ErrInvalidSignature = errors.New("invalid signature")
)

func VerifyPersonalSignature(wallet, signatureHex, message string) error {
	signature, err := hexutil.Decode(signatureHex)
	if err != nil {
		return err
	}
	if len(signature) != 65 {
		return ErrInvalidSignature
	}
	if signature[64] != 27 && signature[64] != 28 {
		return ErrInvalidSignature
	}
	signature[64] -= 27
	hash := accounts.TextHash([]byte(message))
	pubKey, err := crypto.SigToPub(hash, signature)
	if err != nil {
		return err
	}
	recovered := crypto.PubkeyToAddress(*pubKey).Hex()
	if !strings.EqualFold(recovered, wallet) {
		return fmt.Errorf("signature mismatch")
	}
	return nil
}
