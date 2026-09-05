package support

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"

	"codeschool/backend/internal/authctx"
	"codeschool/backend/internal/httpx"
)

type AdminHandler struct {
	service *AdminService
}

func NewAdminHandler(service *AdminService) *AdminHandler {
	return &AdminHandler{service: service}
}

func adminID(c *gin.Context) (int64, bool) {
	id, ok := authctx.UserID(c)
	if !ok {
		httpx.Fail(c, httpx.Unauthorized(httpx.CodeUnauthorized, "Authentication required"))
	}
	return id, ok
}

// List — GET /admin/support/threads
func (h *AdminHandler) List(c *gin.Context) {
	aid, ok := adminID(c)
	if !ok {
		return
	}
	f := AdminFilter{
		Status:   c.Query("status"),
		Category: c.Query("category"),
		Kind:     c.Query("kind"),
		Assigned: c.Query("assigned"),
		Query:    c.Query("q"),
		Page:     atoiOr(c.Query("page"), 1),
		Limit:    atoiOr(c.Query("limit"), 20),
	}
	if f.Status != "" && !validStatus(f.Status) {
		httpx.Fail(c, httpx.BadRequest(httpx.CodeInvalidRequest, "Unknown status filter"))
		return
	}
	if f.Category != "" && !validCategory(f.Category) {
		httpx.Fail(c, httpx.BadRequest(httpx.CodeInvalidRequest, "Unknown category filter"))
		return
	}
	items, meta, err := h.service.List(c.Request.Context(), aid, f)
	if err != nil {
		httpx.Fail(c, mapErr(err))
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": items, "meta": meta})
}

// Get — GET /admin/support/threads/:id
func (h *AdminHandler) Get(c *gin.Context) {
	aid, ok := adminID(c)
	if !ok {
		return
	}
	id, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}
	res, err := h.service.Get(c.Request.Context(), aid, id)
	if err != nil {
		httpx.Fail(c, mapErr(err))
		return
	}
	httpx.OK(c, res)
}

// ListMessages — GET /admin/support/threads/:id/messages
func (h *AdminHandler) ListMessages(c *gin.Context) {
	aid, ok := adminID(c)
	if !ok {
		return
	}
	id, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}
	before, _ := strconv.ParseInt(c.Query("before"), 10, 64)
	limit, _ := strconv.Atoi(c.Query("limit"))
	res, err := h.service.ListMessages(c.Request.Context(), aid, id, before, limit)
	if err != nil {
		httpx.Fail(c, mapErr(err))
		return
	}
	httpx.OK(c, res)
}

// PostMessage — POST /admin/support/threads/:id/messages  {body, internal?}
func (h *AdminHandler) PostMessage(c *gin.Context) {
	aid, ok := adminID(c)
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
	res, err := h.service.PostMessage(c.Request.Context(), aid, id, req.Body, req.Internal)
	if err != nil {
		httpx.Fail(c, mapErr(err))
		return
	}
	httpx.Created(c, res)
}

// InternalNote — POST /admin/support/threads/:id/internal-notes  {body}
// (explicit endpoint kept for clarity; same effect as PostMessage internal=true)
func (h *AdminHandler) InternalNote(c *gin.Context) {
	aid, ok := adminID(c)
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
	res, err := h.service.PostMessage(c.Request.Context(), aid, id, req.Body, true)
	if err != nil {
		httpx.Fail(c, mapErr(err))
		return
	}
	httpx.Created(c, res)
}

// Assign — POST /admin/support/threads/:id/assign  {adminId?}
func (h *AdminHandler) Assign(c *gin.Context) {
	aid, ok := adminID(c)
	if !ok {
		return
	}
	id, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}
	var req AssignRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		httpx.Fail(c, httpx.BadRequest(httpx.CodeInvalidRequest, "Invalid request body"))
		return
	}
	res, err := h.service.Assign(c.Request.Context(), aid, id, req.AdminID)
	if err != nil {
		httpx.Fail(c, mapErr(err))
		return
	}
	httpx.OK(c, res)
}

// SetStatus — POST /admin/support/threads/:id/status  {status}
func (h *AdminHandler) SetStatus(c *gin.Context) {
	aid, ok := adminID(c)
	if !ok {
		return
	}
	id, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}
	var req StatusRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		httpx.Fail(c, httpx.BadRequest(httpx.CodeInvalidRequest, "Invalid request body"))
		return
	}
	res, err := h.service.SetStatus(c.Request.Context(), aid, id, req.Status)
	if err != nil {
		httpx.Fail(c, mapErr(err))
		return
	}
	httpx.OK(c, res)
}

// MarkRead — POST /admin/support/threads/:id/read
func (h *AdminHandler) MarkRead(c *gin.Context) {
	aid, ok := adminID(c)
	if !ok {
		return
	}
	id, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}
	if err := h.service.MarkRead(c.Request.Context(), aid, id); err != nil {
		httpx.Fail(c, mapErr(err))
		return
	}
	httpx.OK(c, gin.H{"ok": true})
}

// UnreadCount — GET /admin/support/unread-count
func (h *AdminHandler) UnreadCount(c *gin.Context) {
	aid, ok := adminID(c)
	if !ok {
		return
	}
	res, err := h.service.UnreadCount(c.Request.Context(), aid)
	if err != nil {
		httpx.Fail(c, mapErr(err))
		return
	}
	httpx.OK(c, res)
}

func atoiOr(s string, def int) int {
	if v, err := strconv.Atoi(s); err == nil {
		return v
	}
	return def
}
