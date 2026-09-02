package programs

import "github.com/gin-gonic/gin"

// RegisterRoutes mounts the programs resource on the given /api/v1 group.
// GET /programs/:id/levels is included here since it's scoped by program id.
func RegisterRoutes(rg *gin.RouterGroup, h *Handler) {
	rg.GET("/programs", h.List)
	rg.GET("/programs/:id", h.GetByID)
	rg.GET("/programs/:id/levels", h.ListLevels)
}
