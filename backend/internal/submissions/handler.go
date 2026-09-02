package submissions

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

// SaveDraft handles PUT /assignments/:id/submission.
func (h *Handler) SaveDraft(c *gin.Context) {
	studentID, assignmentID, ok := h.ids(c)
	if !ok {
		return
	}
	var req UpsertRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		httpx.Fail(c, httpx.BadRequest(httpx.CodeInvalidRequest, "Invalid request body"))
		return
	}

	res, err := h.service.SaveDraft(c.Request.Context(), studentID, assignmentID, req)
	if err != nil {
		httpx.Fail(c, toAPIError(err))
		return
	}
	httpx.OK(c, res)
}

// Submit handles POST /assignments/:id/submit.
func (h *Handler) Submit(c *gin.Context) {
	studentID, assignmentID, ok := h.ids(c)
	if !ok {
		return
	}

	res, err := h.service.Submit(c.Request.Context(), studentID, assignmentID)
	if err != nil {
		httpx.Fail(c, toAPIError(err))
		return
	}
	httpx.OK(c, res)
}

// GetMine handles GET /assignments/:id/submission. When the student has no
// submission yet it returns {"data": null} with 200, so the frontend can
// render an empty editor without special-casing a 404.
func (h *Handler) GetMine(c *gin.Context) {
	studentID, assignmentID, ok := h.ids(c)
	if !ok {
		return
	}

	res, err := h.service.GetMine(c.Request.Context(), studentID, assignmentID)
	if errors.Is(err, ErrNotFound) {
		httpx.OK(c, nil)
		return
	}
	if err != nil {
		httpx.Fail(c, toAPIError(err))
		return
	}
	httpx.OK(c, res)
}

func (h *Handler) ids(c *gin.Context) (studentID, assignmentID int64, ok bool) {
	studentID, ok = authctx.UserID(c)
	if !ok {
		httpx.Fail(c, httpx.Unauthorized(httpx.CodeUnauthorized, "Authentication required"))
		return 0, 0, false
	}
	assignmentID, ok = httpx.ParseIDParam(c, "id")
	if !ok {
		return 0, 0, false
	}
	return studentID, assignmentID, true
}

func toAPIError(err error) error {
	switch {
	case errors.Is(err, ErrAssignmentNotFound), errors.Is(err, ErrNotFound):
		return httpx.NotFound("ASSIGNMENT_NOT_FOUND", "Assignment not found")
	case errors.Is(err, ErrNotEnrolled):
		return httpx.Forbidden(httpx.CodeForbidden, "Enroll in this course to work on its assignments")
	case errors.Is(err, ErrLocked):
		return httpx.Conflict(httpx.CodeConflict, "This submission cannot be edited right now")
	case errors.Is(err, ErrNothingToSubmit):
		return httpx.BadRequest(httpx.CodeInvalidRequest, "Save a draft before submitting")
	default:
		return err
	}
}
