package middleware

import (
	"net/http"

	"airdrop/internal/authctx"
	"airdrop/internal/security"

	"github.com/zeromicro/go-zero/rest/httpx"
)

type AdminMiddleware struct{}

func NewAdminMiddleware() *AdminMiddleware {
	return &AdminMiddleware{}
}

func (m *AdminMiddleware) Handle(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := authctx.FromContext(r.Context())
		if !ok || claims.Role != security.RoleAdmin {
			httpx.WriteJsonCtx(r.Context(), w, http.StatusForbidden, map[string]string{"error": "admin required"})
			return
		}
		next(w, r)
	}
}
