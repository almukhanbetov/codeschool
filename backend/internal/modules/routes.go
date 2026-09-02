package modules

import "github.com/gin-gonic/gin"

// RegisterRoutes mounts the modules resource under the courses URL prefix,
// since a module list is always scoped to its course.
func RegisterRoutes(rg *gin.RouterGroup, h *Handler) {
	rg.GET("/courses/:id/modules", h.ListByCourse)
}
