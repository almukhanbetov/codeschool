package enrollments

import "github.com/gin-gonic/gin"

// RegisterRoutes mounts the student enrollment endpoints. The group passed in
// is expected to already carry the auth middleware + RequireRole("student")
// (see cmd/api/main.go).
func RegisterRoutes(rg *gin.RouterGroup, h *Handler) {
	rg.POST("/courses/:id/enroll", h.Enroll)
	rg.GET("/me/courses", h.ListMyCourses)
}
