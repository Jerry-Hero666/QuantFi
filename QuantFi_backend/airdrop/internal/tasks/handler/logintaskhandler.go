package handler

import (
	"airdrop/internal/entity"
	"airdrop/internal/util"
	"time"

	"encoding/json"

	"gorm.io/datatypes"
	"gorm.io/gorm"
)

type LoginTaskHandler struct {
	params *TaskHandlerParams
}

func (h *LoginTaskHandler) Handle() error {
	now := time.Now().UTC()
	user := &entity.User{}
	if err := h.params.SvcCtx.DB.Where("wallet = ?", h.params.SubmitTask.Wallet).First(user).Error; err != nil {
		return err
	}
	newDay := user.LastLoginAt == nil || !util.SameDay(*user.LastLoginAt, now)
	if newDay {
		if err := h.params.SvcCtx.RunTx(h.params.Ctx, func(tx *gorm.DB) error {
			if user.LastLoginAt != nil && util.IsYesterday(*user.LastLoginAt, now) {
				if user.LoginStreak < 5 {
					user.LoginStreak++
				}
			} else {
				user.LoginStreak = 1
			}
			if user.LoginStreak > 5 {
				user.LoginStreak = 5
			}
			user.LoginDays++
			user.LastLoginAt = &now
			reward := int64(user.LoginStreak) * 100
			if reward > 0 {
				metaBytes, _ := json.Marshal(map[string]interface{}{
					"login_streak": user.LoginStreak,
				})
				ledger := &entity.PointsLedger{
					UserID: user.ID,
					Delta:  reward,
					Reason: "login-streak",
					Meta:   datatypes.JSON(metaBytes),
				}
				if err := tx.Create(ledger).Error; err != nil {
					return err
				}
				user.PointsBalance += reward
			}
			return tx.Save(user).Error
		}); err != nil {
			return err
		}
	}
	return nil
}
