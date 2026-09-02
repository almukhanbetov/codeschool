package lessons

import "github.com/gin-gonic/gin"

// RegisterRoutes mounts the lessons resource: nested under a module for the
// list, and standalone for a single lesson.
func RegisterRoutes(rg *gin.RouterGroup, h *Handler) {
	rg.GET("/modules/:id/lessons", h.ListByModule)
	rg.GET("/lessons/:id", h.GetByID)
}
