package certificates

import "github.com/gin-gonic/gin"

// RegisterPublicRoutes mounts the unauthenticated public verification
// endpoint. The group is the bare /api/v1 group.
func RegisterPublicRoutes(rg *gin.RouterGroup, h *Handler) {
	rg.GET("/certificates/verify/:code", h.Verify)
}

// RegisterLearnerRoutes mounts the owner-scoped certificate endpoints. The
// group already carries auth (any authenticated user — a certificate is
// available to whichever learner completed the course, student or teacher).
func RegisterLearnerRoutes(rg *gin.RouterGroup, h *Handler) {
	rg.GET("/me/certificates", h.ListMine)
	rg.GET("/me/certificates/:id", h.GetMine)
	rg.GET("/me/certificates/:id/pdf", h.MyPDF)
	rg.POST("/courses/:id/certificate", h.Issue)
}

// RegisterAcademyRoutes mounts the Teacher Academy issuance alias under
// /teacher-academy. Same handler, same universal service — no duplicated
// business logic. The group already carries auth + RequireRole("teacher").
func RegisterAcademyRoutes(rg *gin.RouterGroup, h *Handler) {
	rg.POST("/courses/:id/certificate", h.Issue)
}

// RegisterAdminRoutes mounts the admin certificate endpoints under /admin.
// The group already carries auth + RequireRole("admin").
func RegisterAdminRoutes(rg *gin.RouterGroup, h *AdminHandler) {
	a := rg.Group("/admin")
	a.GET("/certificates", h.List)
	a.GET("/certificates/:id", h.Get)
	a.GET("/certificates/:id/pdf", h.PDF)
	a.POST("/certificates/:id/revoke", h.Revoke)
}
