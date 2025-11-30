package security

import (
	"errors"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

type JwtManager struct {
	secret []byte
	expire time.Duration
}

const (
	RoleUser  = "user"
	RoleAdmin = "admin"
)

type Claims struct {
	UID    uint64 `json:"uid"`
	Wallet string `json:"wallet"`
	Role   string `json:"role"`
	jwt.RegisteredClaims
}

func NewJwtManager(secret string, expire time.Duration) *JwtManager {
	if expire <= 0 {
		expire = time.Hour
	}
	return &JwtManager{
		secret: []byte(secret),
		expire: expire,
	}
}

func (m *JwtManager) Generate(uid uint64, wallet, role string) (string, int64, error) {
	exp := time.Now().Add(m.expire)
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, &Claims{
		UID:    uid,
		Wallet: wallet,
		Role:   role,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(exp),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			Subject:   wallet,
		},
	})
	signed, err := token.SignedString(m.secret)
	if err != nil {
		return "", 0, err
	}
	return signed, exp.Unix(), nil
}

func (m *JwtManager) Parse(tokenStr string) (*Claims, error) {
	token, err := jwt.ParseWithClaims(tokenStr, &Claims{}, func(token *jwt.Token) (interface{}, error) {
		if token.Method != jwt.SigningMethodHS256 {
			return nil, errors.New("unexpected signing method")
		}
		return m.secret, nil
	})
	if err != nil {
		return nil, err
	}
	if claims, ok := token.Claims.(*Claims); ok && token.Valid {
		return claims, nil
	}
	return nil, errors.New("invalid token")
}
