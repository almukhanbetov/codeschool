package users

import "github.com/gin-gonic/gin"

// RegisterRoutes mounts the users resource. The group passed in is expected
// to already carry the auth middleware (see cmd/api/main.go) — GET /me is
// always protected.
func RegisterRoutes(rg *gin.RouterGroup, h *Handler) {
	rg.GET("/me", h.Me)
}
