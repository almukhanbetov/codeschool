package quizzes

import "github.com/gin-gonic/gin"

// RegisterStudentRoutes mounts the student quiz endpoints. The group already
// carries auth + RequireRole("student").
func RegisterStudentRoutes(rg *gin.RouterGroup, h *Handler) {
	rg.POST("/assignments/:id/quiz/attempts", h.StartAttempt)
	rg.GET("/assignments/:id/quiz/attempts", h.ListAttempts)
	rg.POST("/quiz/attempts/:id/submit", h.SubmitAttempt)
	rg.GET("/quiz/attempts/:id", h.GetAttempt)
}

// RegisterTeacherRoutes mounts the read-only teacher quiz endpoint. The group
// already carries auth + RequireRole("teacher").
func RegisterTeacherRoutes(rg *gin.RouterGroup, h *Handler) {
	rg.GET("/teacher/quiz/attempts/:id", h.TeacherGetAttempt)
}

// RegisterAdminRoutes mounts the quiz authoring endpoints under /admin. The
// group already carries auth + RequireRole("admin").
func RegisterAdminRoutes(rg *gin.RouterGroup, h *AdminHandler) {
	a := rg.Group("/admin")
	a.GET("/assignments/:id/quiz", h.GetQuiz)
	a.PUT("/assignments/:id/quiz/settings", h.UpdateSettings)
	a.POST("/assignments/:id/quiz/questions", h.CreateQuestion)
	a.PATCH("/quiz/questions/:id", h.UpdateQuestion)
	a.DELETE("/quiz/questions/:id", h.DeleteQuestion)
	a.POST("/quiz/questions/:id/options", h.CreateOption)
	a.PATCH("/quiz/options/:id", h.UpdateOption)
	a.DELETE("/quiz/options/:id", h.DeleteOption)
}
