package academy

import "github.com/gin-gonic/gin"

// RegisterRoutes mounts the Teacher Academy catalog / enrolment / dashboard
// endpoints under /teacher-academy. The group already carries auth +
// RequireRole("teacher"). The actual learning endpoints (lesson start/complete,
// quiz, code runner, assignment submission) are the existing student-flow
// handlers, re-registered on the same group by cmd/api/main.go.
func RegisterRoutes(rg *gin.RouterGroup, h *Handler) {
	rg.GET("/courses", h.ListCourses)
	rg.GET("/courses/:id/content", h.CourseContent)
	rg.POST("/courses/:id/enroll", h.Enroll)
	rg.GET("/me/courses", h.MyCourses)
	rg.GET("/dashboard", h.Dashboard)
}

// RegisterAdminRoutes mounts the admin academy views under /admin/academy.
// The group already carries auth + RequireRole("admin").
func RegisterAdminRoutes(rg *gin.RouterGroup, h *AdminHandler) {
	a := rg.Group("/admin/academy")
	a.GET("/learners", h.Learners)
	a.GET("/submissions", h.Submissions)
	a.GET("/submissions/:id", h.SubmissionDetail)
	a.POST("/submissions/:id/review", h.Review)
}
