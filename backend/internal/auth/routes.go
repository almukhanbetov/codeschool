package auth

import "github.com/gin-gonic/gin"

// RegisterRoutes mounts the public auth endpoints under /api/v1/auth. None of
// these require an access token — refresh and logout authenticate with the
// refresh-token cookie instead.
func RegisterRoutes(rg *gin.RouterGroup, h *Handler) {
	grp := rg.Group("/auth")
	grp.POST("/register", h.Register)
	grp.POST("/login", h.Login)
	grp.POST("/refresh", h.Refresh)
	grp.POST("/logout", h.Logout)
}
