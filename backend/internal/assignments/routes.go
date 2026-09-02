package assignments

import "github.com/gin-gonic/gin"

// RegisterRoutes mounts the student-facing assignment endpoint. The group is
// expected to already carry auth + RequireRole("student").
func RegisterRoutes(rg *gin.RouterGroup, h *Handler) {
	rg.GET("/lessons/:id/assignments", h.ListForLesson)
}
