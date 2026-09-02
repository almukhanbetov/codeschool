package progress

import (
	"errors"

	"github.com/gin-gonic/gin"

	"codeschool/backend/internal/authctx"
	"codeschool/backend/internal/httpx"
)

type Handler struct {
	service *Service
}

func NewHandler(service *Service) *Handler {
	return &Handler{service: service}
}

// StartLesson handles POST /lessons/:id/start.
func (h *Handler) StartLesson(c *gin.Context) {
	studentID, lessonID, ok := h.ids(c)
	if !ok {
		return
	}
	res, err := h.service.StartLesson(c.Request.Context(), studentID, lessonID)
	if err != nil {
		httpx.Fail(c, toAPIError(err))
		return
	}
	httpx.OK(c, res)
}

// CompleteLesson handles POST /lessons/:id/complete.
func (h *Handler) CompleteLesson(c *gin.Context) {
	studentID, lessonID, ok := h.ids(c)
	if !ok {
		return
	}
	res, err := h.service.CompleteLesson(c.Request.Context(), studentID, lessonID)
	if err != nil {
		httpx.Fail(c, toAPIError(err))
		return
	}
	httpx.OK(c, res)
}

// MyProgress handles GET /me/progress.
func (h *Handler) MyProgress(c *gin.Context) {
	studentID, ok := authctx.UserID(c)
	if !ok {
		httpx.Fail(c, httpx.Unauthorized(httpx.CodeUnauthorized, "Authentication required"))
		return
	}
	res, err := h.service.MyProgress(c.Request.Context(), studentID)
	if err != nil {
		httpx.Fail(c, err)
		return
	}
	httpx.OK(c, res)
}

// CourseProgress handles GET /me/courses/:id/progress.
func (h *Handler) CourseProgress(c *gin.Context) {
	studentID, courseID, ok := h.ids(c)
	if !ok {
		return
	}
	res, err := h.service.CourseProgress(c.Request.Context(), studentID, courseID)
	if err != nil {
		httpx.Fail(c, toAPIError(err))
		return
	}
	httpx.OK(c, res)
}

func (h *Handler) ids(c *gin.Context) (studentID, pathID int64, ok bool) {
	studentID, ok = authctx.UserID(c)
	if !ok {
		httpx.Fail(c, httpx.Unauthorized(httpx.CodeUnauthorized, "Authentication required"))
		return 0, 0, false
	}
	pathID, ok = httpx.ParseIDParam(c, "id")
	if !ok {
		return 0, 0, false
	}
	return studentID, pathID, true
}

func toAPIError(err error) error {
	switch {
	case errors.Is(err, ErrLessonNotFound):
		return httpx.NotFound("LESSON_NOT_FOUND", "Lesson not found")
	case errors.Is(err, ErrNotEnrolled):
		return httpx.Forbidden(httpx.CodeForbidden, "Enroll in this course first")
	case errors.Is(err, ErrAssignmentIncomplete):
		return httpx.Conflict(httpx.CodeConflict, "Submit the lesson's assignment before completing it")
	default:
		return err
	}
}
