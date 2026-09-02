package enrollments

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

// Enroll handles POST /courses/:id/enroll. The student id comes from the
// access token — never from the request body.
func (h *Handler) Enroll(c *gin.Context) {
	studentID, ok := authctx.UserID(c)
	if !ok {
		httpx.Fail(c, httpx.Unauthorized(httpx.CodeUnauthorized, "Authentication required"))
		return
	}
	courseID, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}

	res, err := h.service.Enroll(c.Request.Context(), studentID, courseID)
	if err != nil {
		httpx.Fail(c, toAPIError(err))
		return
	}
	httpx.Created(c, res)
}

// ListMyCourses handles GET /me/courses.
func (h *Handler) ListMyCourses(c *gin.Context) {
	studentID, ok := authctx.UserID(c)
	if !ok {
		httpx.Fail(c, httpx.Unauthorized(httpx.CodeUnauthorized, "Authentication required"))
		return
	}

	items, err := h.service.ListMyCourses(c.Request.Context(), studentID)
	if err != nil {
		httpx.Fail(c, err)
		return
	}
	httpx.OK(c, items)
}

func toAPIError(err error) error {
	switch {
	case errors.Is(err, ErrCourseNotAvailable):
		return httpx.NotFound("COURSE_NOT_FOUND", "Course does not exist or is not published")
	case errors.Is(err, ErrAlreadyEnrolled):
		return httpx.Conflict(httpx.CodeConflict, "Already enrolled in this course")
	case errors.Is(err, ErrNotFound):
		return httpx.NotFound("ENROLLMENT_NOT_FOUND", "Enrollment not found")
	default:
		return err
	}
}
