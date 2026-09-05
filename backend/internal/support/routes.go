package support

import "github.com/gin-gonic/gin"

// RegisterUserRoutes mounts the student + parent support endpoints. The group
// already carries auth + RequireRole("student","parent") — teachers have no
// support-chat access.
func RegisterUserRoutes(rg *gin.RouterGroup, h *Handler) {
	s := rg.Group("/support")
	s.GET("/threads", h.ListThreads)
	s.POST("/threads", h.CreateThread)
	s.GET("/unread-count", h.UnreadCount)
	s.GET("/threads/:id", h.GetThread)
	s.GET("/threads/:id/messages", h.ListMessages)
	s.POST("/threads/:id/messages", h.PostMessage)
	s.POST("/threads/:id/read", h.MarkRead)
}

// RegisterAdminRoutes mounts the staff support endpoints under /admin. The
// group already carries auth + RequireRole("admin").
func RegisterAdminRoutes(rg *gin.RouterGroup, h *AdminHandler) {
	a := rg.Group("/admin/support")
	a.GET("/threads", h.List)
	a.GET("/unread-count", h.UnreadCount)
	a.GET("/threads/:id", h.Get)
	a.GET("/threads/:id/messages", h.ListMessages)
	a.POST("/threads/:id/messages", h.PostMessage)
	a.POST("/threads/:id/internal-notes", h.InternalNote)
	a.POST("/threads/:id/assign", h.Assign)
	a.POST("/threads/:id/status", h.SetStatus)
	a.POST("/threads/:id/read", h.MarkRead)
}
