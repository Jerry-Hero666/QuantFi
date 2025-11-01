package handler

import (
	"net/http"

	"github.com/zeromicro/go-zero/rest"
	"github.com/zeromicro/go-zero/rest/httpx"

	"quantfi_backend/internal/svc"
)

func RegisterHandlers(server *rest.Server, ctx *svc.ServiceContext) {
	handler := func(w http.ResponseWriter, r *http.Request) {
		httpx.OkJsonCtx(r.Context(), w, map[string]string{"status": "ok"})
	}

	server.AddRoute(rest.Route{
		Method:  http.MethodGet,
		Path:    "/api/health",
		Handler: handler,
	})
}
