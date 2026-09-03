package runs

import (
	"errors"

	"github.com/gin-gonic/gin"

	"codeschool/backend/internal/authctx"
	"codeschool/backend/internal/httpx"
)

/* ================= student handler ================= */

type Handler struct {
	service *Service
}

func NewHandler(service *Service) *Handler {
	return &Handler{service: service}
}

func studentAndID(c *gin.Context) (int64, int64, bool) {
	sid, ok := authctx.UserID(c)
	if !ok {
		httpx.Fail(c, httpx.Unauthorized(httpx.CodeUnauthorized, "Authentication required"))
		return 0, 0, false
	}
	aid, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return 0, 0, false
	}
	return sid, aid, true
}

// Run handles POST /assignments/:id/run.
func (h *Handler) Run(c *gin.Context) {
	sid, aid, ok := studentAndID(c)
	if !ok {
		return
	}
	var req RunRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		httpx.Fail(c, httpx.BadRequest(httpx.CodeInvalidRequest, "Invalid request body"))
		return
	}
	res, err := h.service.Run(c.Request.Context(), sid, aid, req)
	if err != nil {
		httpx.Fail(c, toAPIError(err))
		return
	}
	httpx.OK(c, res)
}

// History handles GET /assignments/:id/runs.
func (h *Handler) History(c *gin.Context) {
	sid, aid, ok := studentAndID(c)
	if !ok {
		return
	}
	res, err := h.service.History(c.Request.Context(), sid, aid)
	if err != nil {
		httpx.Fail(c, toAPIError(err))
		return
	}
	httpx.OK(c, res)
}

// Tests handles GET /assignments/:id/tests.
func (h *Handler) Tests(c *gin.Context) {
	sid, aid, ok := studentAndID(c)
	if !ok {
		return
	}
	res, err := h.service.VisibleTests(c.Request.Context(), sid, aid)
	if err != nil {
		httpx.Fail(c, toAPIError(err))
		return
	}
	httpx.OK(c, res)
}

// Submit handles POST /assignments/:id/code/submit.
func (h *Handler) Submit(c *gin.Context) {
	sid, aid, ok := studentAndID(c)
	if !ok {
		return
	}
	var req GradeRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		httpx.Fail(c, httpx.BadRequest(httpx.CodeInvalidRequest, "Invalid request body"))
		return
	}
	res, err := h.service.Submit(c.Request.Context(), sid, aid, req)
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

func (h *AdminHandler) List(c *gin.Context) {
	aid, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}
	rows, err := h.service.List(c.Request.Context(), aid)
	if err != nil {
		httpx.Fail(c, toAPIError(err))
		return
	}
	httpx.OK(c, rows)
}

func (h *AdminHandler) Create(c *gin.Context) {
	adminID, ok := authctx.UserID(c)
	if !ok {
		httpx.Fail(c, httpx.Unauthorized(httpx.CodeUnauthorized, "Authentication required"))
		return
	}
	aid, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}
	var req CreateTestRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		httpx.Fail(c, httpx.BadRequest(httpx.CodeInvalidRequest, "Invalid request body"))
		return
	}
	t, err := h.service.Create(c.Request.Context(), adminID, aid, req)
	if err != nil {
		httpx.Fail(c, toAPIError(err))
		return
	}
	httpx.Created(c, t)
}

func (h *AdminHandler) Update(c *gin.Context) {
	adminID, ok := authctx.UserID(c)
	if !ok {
		httpx.Fail(c, httpx.Unauthorized(httpx.CodeUnauthorized, "Authentication required"))
		return
	}
	id, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}
	var req UpdateTestRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		httpx.Fail(c, httpx.BadRequest(httpx.CodeInvalidRequest, "Invalid request body"))
		return
	}
	t, err := h.service.Update(c.Request.Context(), adminID, id, req)
	if err != nil {
		httpx.Fail(c, toAPIError(err))
		return
	}
	httpx.OK(c, t)
}

func (h *AdminHandler) Delete(c *gin.Context) {
	adminID, ok := authctx.UserID(c)
	if !ok {
		httpx.Fail(c, httpx.Unauthorized(httpx.CodeUnauthorized, "Authentication required"))
		return
	}
	id, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}
	if err := h.service.Delete(c.Request.Context(), adminID, id); err != nil {
		httpx.Fail(c, toAPIError(err))
		return
	}
	httpx.OK(c, gin.H{"deleted": true})
}

/* ================= error mapping ================= */

func toAPIError(err error) error {
	var ve *ValidationError
	if errors.As(err, &ve) {
		return httpx.BadRequest(httpx.CodeInvalidRequest, ve.Message)
	}
	switch {
	case errors.Is(err, ErrAssignmentNotFound), errors.Is(err, ErrTestNotFound):
		return httpx.NotFound(httpx.CodeNotFound, "Not found")
	case errors.Is(err, ErrNotCodeAssignment):
		return httpx.BadRequest(httpx.CodeInvalidRequest, "This assignment is not a code assignment")
	case errors.Is(err, ErrNoLanguage):
		return httpx.BadRequest(httpx.CodeInvalidRequest, "This code assignment has no language set")
	case errors.Is(err, ErrNotEnrolled):
		return httpx.Forbidden(httpx.CodeForbidden, "Enroll in this course to run its code assignments")
	case errors.Is(err, ErrThrottled):
		return httpx.Conflict(httpx.CodeConflict, "Too many runs — wait a moment")
	case errors.Is(err, ErrNoTests):
		return httpx.BadRequest(httpx.CodeInvalidRequest, "This assignment has no automated tests")
	case errors.Is(err, ErrRunnerUnavailable):
		return &httpx.APIError{Status: 503, Code: "RUNNER_UNAVAILABLE", Message: "The code runner is unavailable right now"}
	default:
		return err
	}
}
