package authctx

import (
	"context"

	"airdrop/internal/security"
)

type contextKey string

const claimsKey contextKey = "airdropClaims"

func WithClaims(ctx context.Context, claims *security.Claims) context.Context {
	return context.WithValue(ctx, claimsKey, claims)
}

func FromContext(ctx context.Context) (*security.Claims, bool) {
	v, ok := ctx.Value(claimsKey).(*security.Claims)
	return v, ok && v != nil
}
