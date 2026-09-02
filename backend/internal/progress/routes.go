package progress

import "github.com/gin-gonic/gin"

// RegisterRoutes mounts the student progress endpoints. The group is expected
// to already carry auth + RequireRole("student").
func RegisterRoutes(rg *gin.RouterGroup, h *Handler) {
	rg.POST("/lessons/:id/start", h.StartLesson)
	rg.POST("/lessons/:id/complete", h.CompleteLesson)
	rg.GET("/me/progress", h.MyProgress)
	rg.GET("/me/courses/:id/progress", h.CourseProgress)
}
