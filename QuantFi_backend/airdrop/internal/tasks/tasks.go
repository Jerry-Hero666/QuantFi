package tasks

import (
	"errors"
	"fmt"
	"strings"

	"github.com/google/uuid"
)

const (
	TaskPromote  = "PROMO"
	TaskInvest   = "INVEST"
	TaskReferral = "REFERRAL"
)

type Rule struct {
	Code      string
	Once      bool
	BasePoint int64
	MaxPoint  int64
}

var (
	ErrUnknownTask   = errors.New("unknown task")
	ErrInvalidAmount = errors.New("invalid amount")
	ErrInvalidExtra  = errors.New("invalid extra parameter")
)

func Normalize(code string) string {
	return strings.ToUpper(strings.TrimSpace(code))
}

func PointsFor(task string, amount int64) (int64, error) {
	switch task {
	case TaskPromote:
		return 1000, nil
	case TaskInvest:
		if amount <= 0 {
			return 0, ErrInvalidAmount
		}
		return amount, nil
	case TaskReferral:
		return 500, nil
	default:
		return 0, ErrUnknownTask
	}
}

// UniqueKey generates the unique key written to user_tasks.unique_key to enforce constraints.
func UniqueKey(task, extra string) (string, error) {
	switch task {
	case TaskPromote:
		return "promo-once", nil
	case TaskReferral:
		if extra == "" {
			return "", ErrInvalidExtra
		}
		return fmt.Sprintf("ref-%s", strings.ToLower(extra)), nil
	case TaskInvest:
		return uuid.NewString(), nil
	default:
		return "", ErrUnknownTask
	}
}
