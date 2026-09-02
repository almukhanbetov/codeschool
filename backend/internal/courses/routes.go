package courses

import "github.com/gin-gonic/gin"

func RegisterRoutes(rg *gin.RouterGroup, h *Handler) {
	rg.GET("/courses", h.List)
	rg.GET("/courses/:id", h.GetByID)
	rg.GET("/courses/slug/:slug", h.GetBySlug)
	rg.GET("/courses/:id/content", h.GetContent)
}
