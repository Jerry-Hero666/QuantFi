package svc

import (
	"context"
	"encoding/json"
	"errors"

	"airdrop/internal/entity"

	"gorm.io/datatypes"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

var (
	ErrInsufficientPoints = errors.New("insufficient points")
)

func (s *ServiceContext) withTx(ctx context.Context, fn func(tx *gorm.DB) error) error {
	return s.DB.WithContext(ctx).Transaction(fn)
}

func (s *ServiceContext) awardPoints(ctx context.Context, user *entity.User, delta int64, reason string, meta map[string]interface{}, tx *gorm.DB) error {
	if delta == 0 {
		return nil
	}
	payload := datatypes.JSON(nil)
	if len(meta) > 0 {
		if bytes, err := json.Marshal(meta); err == nil {
			payload = datatypes.JSON(bytes)
		}
	}
	if err := tx.Clauses(clause.Locking{Strength: "UPDATE"}).Where("id = ?", user.ID).First(user).Error; err != nil {
		return err
	}
	user.PointsBalance += delta
	if err := tx.Save(user).Error; err != nil {
		return err
	}
	ledger := &entity.PointsLedger{
		UserID: user.ID,
		Delta:  delta,
		Reason: reason,
		Meta:   payload,
	}
	return tx.Create(ledger).Error
}

func (s *ServiceContext) RunTx(ctx context.Context, fn func(tx *gorm.DB) error) error {
	return s.withTx(ctx, fn)
}

func (s *ServiceContext) AwardPointsInTx(ctx context.Context, user *entity.User, delta int64, reason string, meta map[string]interface{}, tx *gorm.DB) error {
	return s.awardPoints(ctx, user, delta, reason, meta, tx)
}

func (s *ServiceContext) SnapshotRound(ctx context.Context, round *entity.AirdropRound) error {
	return s.withTx(ctx, func(tx *gorm.DB) error {
		var users []entity.User
		if err := tx.Find(&users).Error; err != nil {
			return err
		}
		for i := range users {
			u := users[i]
			if u.PointsBalance == 0 {
				continue
			}
			entry := entity.RoundPoint{
				RoundID: round.ID,
				UserID:  u.ID,
				Points:  u.PointsBalance,
			}
			if err := tx.Create(&entry).Error; err != nil {
				return err
			}
			u.FrozenPoints = u.PointsBalance
			u.PointsBalance = 0
			if err := tx.Save(&u).Error; err != nil {
				return err
			}
			ledger := &entity.PointsLedger{
				UserID: u.ID,
				Delta:  -entry.Points,
				Reason: "start round",
			}
			if err := tx.Create(ledger).Error; err != nil {
				return err
			}
		}
		return nil
	})
}
