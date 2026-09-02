package submissions

import "github.com/gin-gonic/gin"

// RegisterRoutes mounts the student submission endpoints. The group is
// expected to already carry auth + RequireRole("student").
func RegisterRoutes(rg *gin.RouterGroup, h *Handler) {
	rg.PUT("/assignments/:id/submission", h.SaveDraft)
	rg.GET("/assignments/:id/submission", h.GetMine)
	rg.POST("/assignments/:id/submit", h.Submit)
}
