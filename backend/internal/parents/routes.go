package parents

import "github.com/gin-gonic/gin"

// RegisterRoutes mounts the read-only parent endpoints under /parent. The
// group is expected to already carry auth + RequireRole("parent"). Every
// route is a GET — the parent flow never mutates state.
func RegisterRoutes(rg *gin.RouterGroup, h *Handler) {
	p := rg.Group("/parent")
	p.GET("/children", h.ListChildren)
	p.GET("/children/:id", h.GetChild)
	p.GET("/children/:id/courses/:courseId", h.GetChildCourse)
	p.GET("/children/:id/activity", h.GetChildActivity)
}
