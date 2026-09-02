package levels

import "github.com/gin-gonic/gin"

// RegisterRoutes mounts the levels resource's own standalone endpoint.
// GET /programs/:id/levels is registered by the programs package instead,
// since that route is scoped by program id.
func RegisterRoutes(rg *gin.RouterGroup, h *Handler) {
	rg.GET("/levels/:id", h.GetByID)
}
