package parents

import (
	"errors"
	"strconv"

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

func (h *Handler) parentID(c *gin.Context) (int64, bool) {
	id, ok := authctx.UserID(c)
	if !ok {
		httpx.Fail(c, httpx.Unauthorized(httpx.CodeUnauthorized, "Authentication required"))
		return 0, false
	}
	return id, true
}

func parsePositive(c *gin.Context, name, label string) (int64, bool) {
	v, err := strconv.ParseInt(c.Param(name), 10, 64)
	if err != nil || v <= 0 {
		httpx.Fail(c, httpx.BadRequest("INVALID_ID", label+" must be a positive integer"))
		return 0, false
	}
	return v, true
}

// GET /parent/children
func (h *Handler) ListChildren(c *gin.Context) {
	pid, ok := h.parentID(c)
	if !ok {
		return
	}
	items, err := h.service.ListChildren(c.Request.Context(), pid)
	if err != nil {
		httpx.Fail(c, err)
		return
	}
	httpx.OK(c, items)
}

// GET /parent/children/:id
func (h *Handler) GetChild(c *gin.Context) {
	pid, ok := h.parentID(c)
	if !ok {
		return
	}
	childID, ok := parsePositive(c, "id", "childId")
	if !ok {
		return
	}
	d, err := h.service.GetChild(c.Request.Context(), pid, childID)
	if err != nil {
		httpx.Fail(c, mapErr(err))
		return
	}
	httpx.OK(c, d)
}

// GET /parent/children/:id/courses/:courseId
func (h *Handler) GetChildCourse(c *gin.Context) {
	pid, ok := h.parentID(c)
	if !ok {
		return
	}
	childID, ok := parsePositive(c, "id", "childId")
	if !ok {
		return
	}
	courseID, ok := parsePositive(c, "courseId", "courseId")
	if !ok {
		return
	}
	d, err := h.service.GetChildCourse(c.Request.Context(), pid, childID, courseID)
	if err != nil {
		httpx.Fail(c, mapErr(err))
		return
	}
	httpx.OK(c, d)
}

// GET /parent/children/:id/activity
func (h *Handler) GetChildActivity(c *gin.Context) {
	pid, ok := h.parentID(c)
	if !ok {
		return
	}
	childID, ok := parsePositive(c, "id", "childId")
	if !ok {
		return
	}
	d, err := h.service.GetChildActivity(c.Request.Context(), pid, childID)
	if err != nil {
		httpx.Fail(c, mapErr(err))
		return
	}
	httpx.OK(c, d)
}

func mapErr(err error) error {
	switch {
	case errors.Is(err, ErrChildNotFound):
		return httpx.NotFound("CHILD_NOT_FOUND", "Child not found")
	case errors.Is(err, ErrCourseNotFound):
		return httpx.NotFound("COURSE_NOT_FOUND", "Course not found for this child")
	default:
		return err
	}
}
