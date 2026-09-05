package support

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

func caller(c *gin.Context) (id int64, role string, ok bool) {
	id, ok = authctx.UserID(c)
	if !ok {
		httpx.Fail(c, httpx.Unauthorized(httpx.CodeUnauthorized, "Authentication required"))
		return 0, "", false
	}
	role, _ = authctx.Role(c)
	return id, role, true
}

func qInt64(c *gin.Context, key string) int64 {
	v, _ := strconv.ParseInt(c.Query(key), 10, 64)
	if v < 0 {
		return 0
	}
	return v
}

// ListThreads — GET /support/threads
func (h *Handler) ListThreads(c *gin.Context) {
	uid, _, ok := caller(c)
	if !ok {
		return
	}
	res, err := h.service.ListThreads(c.Request.Context(), uid)
	if err != nil {
		httpx.Fail(c, mapErr(err))
		return
	}
	httpx.OK(c, res)
}

// CreateThread — POST /support/threads
func (h *Handler) CreateThread(c *gin.Context) {
	uid, role, ok := caller(c)
	if !ok {
		return
	}
	var req CreateThreadRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		httpx.Fail(c, httpx.BadRequest(httpx.CodeInvalidRequest, "Invalid request body"))
		return
	}
	res, err := h.service.CreateThread(c.Request.Context(), uid, role, req)
	if err != nil {
		httpx.Fail(c, mapErr(err))
		return
	}
	httpx.Created(c, res)
}

// GetThread — GET /support/threads/:id
func (h *Handler) GetThread(c *gin.Context) {
	uid, _, ok := caller(c)
	if !ok {
		return
	}
	id, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}
	res, err := h.service.GetThread(c.Request.Context(), uid, id)
	if err != nil {
		httpx.Fail(c, mapErr(err))
		return
	}
	httpx.OK(c, res)
}

// ListMessages — GET /support/threads/:id/messages?before=&limit=
func (h *Handler) ListMessages(c *gin.Context) {
	uid, _, ok := caller(c)
	if !ok {
		return
	}
	id, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}
	limit, _ := strconv.Atoi(c.Query("limit"))
	res, err := h.service.ListMessages(c.Request.Context(), uid, id, qInt64(c, "before"), limit)
	if err != nil {
		httpx.Fail(c, mapErr(err))
		return
	}
	httpx.OK(c, res)
}

// PostMessage — POST /support/threads/:id/messages
func (h *Handler) PostMessage(c *gin.Context) {
	uid, role, ok := caller(c)
	if !ok {
		return
	}
	id, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}
	var req CreateMessageRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		httpx.Fail(c, httpx.BadRequest(httpx.CodeInvalidRequest, "Invalid request body"))
		return
	}
	res, err := h.service.PostMessage(c.Request.Context(), uid, role, id, req.Body)
	if err != nil {
		httpx.Fail(c, mapErr(err))
		return
	}
	httpx.Created(c, res)
}

// MarkRead — POST /support/threads/:id/read
func (h *Handler) MarkRead(c *gin.Context) {
	uid, _, ok := caller(c)
	if !ok {
		return
	}
	id, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}
	if err := h.service.MarkRead(c.Request.Context(), uid, id); err != nil {
		httpx.Fail(c, mapErr(err))
		return
	}
	httpx.OK(c, gin.H{"ok": true})
}

// UnreadCount — GET /support/unread-count
func (h *Handler) UnreadCount(c *gin.Context) {
	uid, _, ok := caller(c)
	if !ok {
		return
	}
	res, err := h.service.UnreadCount(c.Request.Context(), uid)
	if err != nil {
		httpx.Fail(c, mapErr(err))
		return
	}
	httpx.OK(c, res)
}

/* ================= error mapping ================= */

func mapErr(err error) error {
	switch {
	case err == nil:
		return nil
	case errors.Is(err, ErrThreadNotFound):
		return httpx.NotFound(httpx.CodeNotFound, "Thread not found")
	case errors.Is(err, ErrForbiddenChild):
		return httpx.Forbidden(httpx.CodeForbidden, "You can only open a thread about your own linked child")
	case errors.Is(err, ErrCourseAccess):
		return httpx.Forbidden(httpx.CodeForbidden, "No access to the referenced course")
	case errors.Is(err, ErrInvalidCategory):
		return httpx.BadRequest(httpx.CodeInvalidRequest, "Unknown category")
	case errors.Is(err, ErrInvalidStatus):
		return httpx.BadRequest(httpx.CodeInvalidRequest, "Unknown status")
	case errors.Is(err, ErrSubjectRequired):
		return httpx.BadRequest(httpx.CodeInvalidRequest, "A subject is required")
	case errors.Is(err, ErrEmptyMessage):
		return httpx.BadRequest(httpx.CodeInvalidRequest, "A message is required")
	case errors.Is(err, ErrMessageTooLong):
		return httpx.BadRequest(httpx.CodeInvalidRequest, "Message must be at most 4000 characters")
	case errors.Is(err, ErrNotAnAdmin):
		return httpx.BadRequest(httpx.CodeInvalidRequest, "Can only assign a thread to an admin")
	default:
		return err
	}
}
