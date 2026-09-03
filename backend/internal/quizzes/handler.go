package quizzes

import (
	"errors"

	"github.com/gin-gonic/gin"

	"codeschool/backend/internal/authctx"
	"codeschool/backend/internal/httpx"
)

/* ================= student + teacher handler ================= */

type Handler struct {
	service *Service
}

func NewHandler(service *Service) *Handler {
	return &Handler{service: service}
}

func userID(c *gin.Context) (int64, bool) {
	id, ok := authctx.UserID(c)
	if !ok {
		httpx.Fail(c, httpx.Unauthorized(httpx.CodeUnauthorized, "Authentication required"))
	}
	return id, ok
}

// StartAttempt handles POST /assignments/:id/quiz/attempts.
func (h *Handler) StartAttempt(c *gin.Context) {
	studentID, ok := userID(c)
	if !ok {
		return
	}
	assignmentID, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}
	res, err := h.service.StartAttempt(c.Request.Context(), studentID, assignmentID)
	if err != nil {
		httpx.Fail(c, toAPIError(err))
		return
	}
	httpx.Created(c, res)
}

// ListAttempts handles GET /assignments/:id/quiz/attempts.
func (h *Handler) ListAttempts(c *gin.Context) {
	studentID, ok := userID(c)
	if !ok {
		return
	}
	assignmentID, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}
	res, err := h.service.ListAttempts(c.Request.Context(), studentID, assignmentID)
	if err != nil {
		httpx.Fail(c, toAPIError(err))
		return
	}
	httpx.OK(c, res)
}

// SubmitAttempt handles POST /quiz/attempts/:id/submit.
func (h *Handler) SubmitAttempt(c *gin.Context) {
	studentID, ok := userID(c)
	if !ok {
		return
	}
	attemptID, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}
	var req SubmitRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		httpx.Fail(c, httpx.BadRequest(httpx.CodeInvalidRequest, "Invalid request body"))
		return
	}
	res, err := h.service.SubmitAttempt(c.Request.Context(), studentID, attemptID, req)
	if err != nil {
		httpx.Fail(c, toAPIError(err))
		return
	}
	httpx.OK(c, res)
}

// GetAttempt handles GET /quiz/attempts/:id.
func (h *Handler) GetAttempt(c *gin.Context) {
	studentID, ok := userID(c)
	if !ok {
		return
	}
	attemptID, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}
	res, err := h.service.GetAttempt(c.Request.Context(), studentID, attemptID)
	if err != nil {
		httpx.Fail(c, toAPIError(err))
		return
	}
	httpx.OK(c, res)
}

// TeacherGetAttempt handles GET /teacher/quiz/attempts/:id.
func (h *Handler) TeacherGetAttempt(c *gin.Context) {
	teacherID, ok := userID(c)
	if !ok {
		return
	}
	attemptID, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}
	res, err := h.service.TeacherAttempt(c.Request.Context(), teacherID, attemptID)
	if err != nil {
		httpx.Fail(c, toAPIError(err))
		return
	}
	httpx.OK(c, res)
}

/* ================= admin handler ================= */

type AdminHandler struct {
	service *AdminService
}

func NewAdminHandler(service *AdminService) *AdminHandler {
	return &AdminHandler{service: service}
}

func adminBind[T any](c *gin.Context) (T, bool) {
	var v T
	if err := c.ShouldBindJSON(&v); err != nil {
		httpx.Fail(c, httpx.BadRequest(httpx.CodeInvalidRequest, "Invalid request body"))
		return v, false
	}
	return v, true
}

func (h *AdminHandler) GetQuiz(c *gin.Context) {
	assignmentID, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}
	res, err := h.service.GetQuiz(c.Request.Context(), assignmentID)
	if err != nil {
		httpx.Fail(c, toAPIError(err))
		return
	}
	httpx.OK(c, res)
}

func (h *AdminHandler) UpdateSettings(c *gin.Context) {
	adminID, ok := userID(c)
	if !ok {
		return
	}
	assignmentID, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}
	req, ok := adminBind[UpdateSettingsRequest](c)
	if !ok {
		return
	}
	res, err := h.service.UpdateSettings(c.Request.Context(), adminID, assignmentID, req)
	if err != nil {
		httpx.Fail(c, toAPIError(err))
		return
	}
	httpx.OK(c, res)
}

func (h *AdminHandler) CreateQuestion(c *gin.Context) {
	adminID, ok := userID(c)
	if !ok {
		return
	}
	assignmentID, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}
	req, ok := adminBind[CreateQuestionRequest](c)
	if !ok {
		return
	}
	res, err := h.service.CreateQuestion(c.Request.Context(), adminID, assignmentID, req)
	if err != nil {
		httpx.Fail(c, toAPIError(err))
		return
	}
	httpx.Created(c, res)
}

func (h *AdminHandler) UpdateQuestion(c *gin.Context) {
	adminID, ok := userID(c)
	if !ok {
		return
	}
	questionID, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}
	req, ok := adminBind[UpdateQuestionRequest](c)
	if !ok {
		return
	}
	res, err := h.service.UpdateQuestion(c.Request.Context(), adminID, questionID, req)
	if err != nil {
		httpx.Fail(c, toAPIError(err))
		return
	}
	httpx.OK(c, res)
}

func (h *AdminHandler) DeleteQuestion(c *gin.Context) {
	adminID, ok := userID(c)
	if !ok {
		return
	}
	questionID, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}
	res, err := h.service.DeleteQuestion(c.Request.Context(), adminID, questionID)
	if err != nil {
		httpx.Fail(c, toAPIError(err))
		return
	}
	httpx.OK(c, res)
}

func (h *AdminHandler) CreateOption(c *gin.Context) {
	adminID, ok := userID(c)
	if !ok {
		return
	}
	questionID, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}
	req, ok := adminBind[CreateOptionRequest](c)
	if !ok {
		return
	}
	res, err := h.service.CreateOption(c.Request.Context(), adminID, questionID, req)
	if err != nil {
		httpx.Fail(c, toAPIError(err))
		return
	}
	httpx.Created(c, res)
}

func (h *AdminHandler) UpdateOption(c *gin.Context) {
	adminID, ok := userID(c)
	if !ok {
		return
	}
	optionID, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}
	req, ok := adminBind[UpdateOptionRequest](c)
	if !ok {
		return
	}
	res, err := h.service.UpdateOption(c.Request.Context(), adminID, optionID, req)
	if err != nil {
		httpx.Fail(c, toAPIError(err))
		return
	}
	httpx.OK(c, res)
}

func (h *AdminHandler) DeleteOption(c *gin.Context) {
	adminID, ok := userID(c)
	if !ok {
		return
	}
	optionID, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}
	res, err := h.service.DeleteOption(c.Request.Context(), adminID, optionID)
	if err != nil {
		httpx.Fail(c, toAPIError(err))
		return
	}
	httpx.OK(c, res)
}

/* ================= error mapping ================= */

func toAPIError(err error) error {
	var ve *ValidationError
	if errors.As(err, &ve) {
		return httpx.BadRequest(httpx.CodeInvalidRequest, ve.Message)
	}
	switch {
	case errors.Is(err, ErrQuizNotFound), errors.Is(err, ErrQuestionNotFound),
		errors.Is(err, ErrOptionNotFound), errors.Is(err, ErrAttemptNotFound):
		return httpx.NotFound(httpx.CodeNotFound, "Not found")
	case errors.Is(err, ErrNotQuizAssignment):
		return httpx.BadRequest(httpx.CodeInvalidRequest, "This assignment is not a quiz")
	case errors.Is(err, ErrNotEnrolled):
		return httpx.Forbidden(httpx.CodeForbidden, "Enroll in this course to take its quizzes")
	case errors.Is(err, ErrAttemptNotOwned):
		return httpx.Forbidden(httpx.CodeForbidden, "This attempt belongs to another student")
	case errors.Is(err, ErrAttemptClosed):
		return httpx.Conflict(httpx.CodeConflict, "This attempt has already been submitted")
	case errors.Is(err, ErrMaxAttempts):
		return httpx.Conflict(httpx.CodeConflict, "You have used all your attempts for this quiz")
	case errors.Is(err, ErrNoQuestions):
		return httpx.Conflict(httpx.CodeConflict, "This quiz has no questions yet")
	case errors.Is(err, ErrQuizMisconfigured):
		return httpx.Conflict(httpx.CodeConflict, "This quiz is not fully configured yet")
	default:
		return err
	}
}
