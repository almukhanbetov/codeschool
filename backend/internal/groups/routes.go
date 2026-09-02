package groups

import "github.com/gin-gonic/gin"

// RegisterRoutes mounts the teacher endpoints under /teacher. The group is
// expected to already carry auth + RequireRole("teacher").
func RegisterRoutes(rg *gin.RouterGroup, h *Handler) {
	t := rg.Group("/teacher")
	t.GET("/dashboard", h.Dashboard)
	t.GET("/groups", h.ListGroups)
	t.GET("/groups/:id", h.GetGroup)
	t.GET("/groups/:id/students", h.ListGroupStudents)
	t.GET("/groups/:id/students/:studentId", h.GetGroupStudent)
	t.GET("/submissions", h.ListSubmissions)
	t.GET("/submissions/:id", h.GetSubmission)
	t.POST("/submissions/:id/start-review", h.StartReview)
	t.POST("/submissions/:id/review", h.Review)
}
