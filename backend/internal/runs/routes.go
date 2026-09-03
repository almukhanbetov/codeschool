package runs

import "github.com/gin-gonic/gin"

// RegisterStudentRoutes mounts the student code-runner endpoints. The group
// already carries auth + RequireRole("student").
func RegisterStudentRoutes(rg *gin.RouterGroup, h *Handler) {
	rg.POST("/assignments/:id/run", h.Run)
	rg.GET("/assignments/:id/runs", h.History)
	rg.GET("/assignments/:id/tests", h.Tests)
	rg.POST("/assignments/:id/code/submit", h.Submit)
}

// RegisterAdminRoutes mounts test-case authoring under /admin. The group
// already carries auth + RequireRole("admin").
func RegisterAdminRoutes(rg *gin.RouterGroup, h *AdminHandler) {
	a := rg.Group("/admin")
	a.GET("/assignments/:id/tests", h.List)
	a.POST("/assignments/:id/tests", h.Create)
	a.PATCH("/tests/:id", h.Update)
	a.DELETE("/tests/:id", h.Delete)
}
