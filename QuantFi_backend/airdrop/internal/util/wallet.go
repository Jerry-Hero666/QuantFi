package util

import (
	"errors"
	"strings"

	"github.com/ethereum/go-ethereum/common"
)

// NormalizeWallet ensures wallet addresses are checksum-formatted.
func NormalizeWallet(addr string) (string, error) {
	if !common.IsHexAddress(addr) {
		return "", ErrInvalidWallet
	}
	return strings.ToLower(common.HexToAddress(addr).Hex()), nil
}

var ErrInvalidWallet = errors.New("invalid wallet address")
