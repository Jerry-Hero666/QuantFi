package middleware

import (
	"net/http"
	"strings"

	"airdrop/internal/authctx"
	"airdrop/internal/security"

	"github.com/zeromicro/go-zero/rest/httpx"
)

type JWTMiddleware struct {
	manager *security.JwtManager
}

func NewJWTMiddleware(manager *security.JwtManager) *JWTMiddleware {
	return &JWTMiddleware{manager: manager}
}

func (m *JWTMiddleware) Handle(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if r.Method == http.MethodOptions {
			next(w, r)
			return
		}
		token := extractToken(r)
		if token == "" {
			httpx.WriteJsonCtx(r.Context(), w, http.StatusUnauthorized, map[string]string{"error": "missing token"})
			return
		}
		claims, err := m.manager.Parse(token)
		if err != nil {
			httpx.WriteJsonCtx(r.Context(), w, http.StatusUnauthorized, map[string]string{"error": "invalid token"})
			return
		}
		ctx := authctx.WithClaims(r.Context(), claims)
		next(w, r.WithContext(ctx))
	}
}

func extractToken(r *http.Request) string {
	authHeader := r.Header.Get("Authorization")
	if authHeader == "" {
		return ""
	}
	parts := strings.SplitN(authHeader, " ", 2)
	if len(parts) != 2 {
		return ""
	}
	if !strings.EqualFold(parts[0], "Bearer") {
		return ""
	}
	return strings.TrimSpace(parts[1])
}
