package assignments

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

// ListForLesson handles GET /lessons/:id/assignments (enrolled students only).
func (h *Handler) ListForLesson(c *gin.Context) {
	studentID, ok := authctx.UserID(c)
	if !ok {
		httpx.Fail(c, httpx.Unauthorized(httpx.CodeUnauthorized, "Authentication required"))
		return
	}
	lessonID, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}

	items, err := h.service.ListForLesson(c.Request.Context(), studentID, lessonID)
	if err != nil {
		httpx.Fail(c, toAPIError(err))
		return
	}
	httpx.OK(c, items)
}

func toAPIError(err error) error {
	switch {
	case errors.Is(err, ErrLessonNotFound), errors.Is(err, ErrNotFound):
		return httpx.NotFound("LESSON_NOT_FOUND", "Lesson not found")
	case errors.Is(err, ErrNotEnrolled):
		return httpx.Forbidden(httpx.CodeForbidden, "Enroll in this course to access its assignments")
	default:
		return err
	}
}
