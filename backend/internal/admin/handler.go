package admin

import (
	"errors"
	"net/http"
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

/* ---- shared helpers ---- */

func (h *Handler) actor(c *gin.Context) (int64, bool) {
	id, ok := authctx.UserID(c)
	if !ok {
		httpx.Fail(c, httpx.Unauthorized(httpx.CodeUnauthorized, "Authentication required"))
	}
	return id, ok
}

func idParam(c *gin.Context, name string) (int64, bool) {
	v, err := strconv.ParseInt(c.Param(name), 10, 64)
	if err != nil || v <= 0 {
		httpx.Fail(c, httpx.BadRequest("INVALID_ID", name+" must be a positive integer"))
		return 0, false
	}
	return v, true
}

func bind[T any](c *gin.Context) (T, bool) {
	var v T
	if err := c.ShouldBindJSON(&v); err != nil {
		httpx.Fail(c, httpx.BadRequest(httpx.CodeInvalidRequest, "Invalid request body"))
		return v, false
	}
	return v, true
}

func queryI64(c *gin.Context, key string) (*int64, bool) {
	raw := c.Query(key)
	if raw == "" {
		return nil, true
	}
	v, err := strconv.ParseInt(raw, 10, 64)
	if err != nil || v <= 0 {
		httpx.Fail(c, httpx.BadRequest("INVALID_QUERY", key+" must be a positive integer"))
		return nil, false
	}
	return &v, true
}

func queryBool(c *gin.Context, key string) (*bool, bool) {
	raw := c.Query(key)
	if raw == "" {
		return nil, true
	}
	v, err := strconv.ParseBool(raw)
	if err != nil {
		httpx.Fail(c, httpx.BadRequest("INVALID_QUERY", key+" must be true or false"))
		return nil, false
	}
	return &v, true
}

func atoiOr(s string, def int) int {
	if v, err := strconv.Atoi(s); err == nil {
		return v
	}
	return def
}

// mapErr turns an admin sentinel / ValidationError into the shared envelope.
func mapErr(err error) error {
	var ve *ValidationError
	if errors.As(err, &ve) {
		return httpx.BadRequest(httpx.CodeInvalidRequest, ve.Message)
	}
	switch {
	case errors.Is(err, ErrNotFound):
		return httpx.NotFound(httpx.CodeNotFound, "Not found")
	case errors.Is(err, ErrConflict):
		return httpx.Conflict(httpx.CodeConflict, "That value is already in use")
	case errors.Is(err, ErrDuplicateEmail):
		return httpx.Conflict(httpx.CodeConflict, "Email already in use")
	case errors.Is(err, ErrDuplicatePhone):
		return httpx.Conflict(httpx.CodeConflict, "Phone already in use")
	case errors.Is(err, ErrValidation):
		return httpx.BadRequest(httpx.CodeInvalidRequest, "Referenced record does not exist or the value is invalid")
	case errors.Is(err, ErrRoleMismatch):
		return httpx.BadRequest(httpx.CodeInvalidRequest, "The user does not have the required role")
	case errors.Is(err, ErrLastAdmin):
		return httpx.Conflict(httpx.CodeConflict, "Cannot remove the last active admin")
	case errors.Is(err, ErrSelfMutation):
		return httpx.Forbidden(httpx.CodeForbidden, "You cannot delete or deactivate your own account")
	case errors.Is(err, ErrInUse):
		return httpx.Conflict(httpx.CodeConflict, "That record is still referenced elsewhere")
	default:
		return err
	}
}

func respond(c *gin.Context, data any) { httpx.OK(c, data) }
func created(c *gin.Context, data any) { httpx.Created(c, data) }
func paged(c *gin.Context, data any, meta ListMeta) {
	c.JSON(http.StatusOK, gin.H{"data": data, "meta": meta})
}
func fail(c *gin.Context, err error) { httpx.Fail(c, mapErr(err)) }

/* ---- overview / audit ---- */

func (h *Handler) Overview(c *gin.Context) {
	o, err := h.service.Overview(c.Request.Context())
	if err != nil {
		fail(c, err)
		return
	}
	respond(c, o)
}

func (h *Handler) ListAudit(c *gin.Context) {
	rows, meta, err := h.service.ListAudit(c.Request.Context(),
		atoiOr(c.Query("page"), 1), atoiOr(c.Query("limit"), 25))
	if err != nil {
		fail(c, err)
		return
	}
	paged(c, rows, meta)
}

/* ---- users ---- */

func (h *Handler) ListUsers(c *gin.Context) {
	f := UserFilter{
		Role:   c.Query("role"),
		Search: c.Query("search"),
		Page:   atoiOr(c.Query("page"), 1),
		Limit:  atoiOr(c.Query("limit"), 25),
	}
	active, okQ := queryBool(c, "active")
	if !okQ {
		return
	}
	f.Active = active
	rows, meta, err := h.service.ListUsers(c.Request.Context(), f)
	if err != nil {
		fail(c, err)
		return
	}
	paged(c, rows, meta)
}

func (h *Handler) GetUser(c *gin.Context) {
	id, okP := idParam(c, "id")
	if !okP {
		return
	}
	u, err := h.service.GetUser(c.Request.Context(), id)
	if err != nil {
		fail(c, err)
		return
	}
	respond(c, u)
}

func (h *Handler) CreateUser(c *gin.Context) {
	adminID, okA := h.actor(c)
	if !okA {
		return
	}
	req, okB := bind[CreateUserRequest](c)
	if !okB {
		return
	}
	u, err := h.service.CreateUser(c.Request.Context(), adminID, req)
	if err != nil {
		fail(c, err)
		return
	}
	created(c, u)
}

func (h *Handler) UpdateUser(c *gin.Context) {
	adminID, okA := h.actor(c)
	if !okA {
		return
	}
	id, okP := idParam(c, "id")
	if !okP {
		return
	}
	req, okB := bind[UpdateUserRequest](c)
	if !okB {
		return
	}
	u, err := h.service.UpdateUser(c.Request.Context(), adminID, id, req)
	if err != nil {
		fail(c, err)
		return
	}
	respond(c, u)
}

func (h *Handler) DeleteUser(c *gin.Context) {
	adminID, okA := h.actor(c)
	if !okA {
		return
	}
	id, okP := idParam(c, "id")
	if !okP {
		return
	}
	if err := h.service.DeleteUser(c.Request.Context(), adminID, id); err != nil {
		fail(c, err)
		return
	}
	respond(c, gin.H{"deleted": true})
}

func (h *Handler) SetPassword(c *gin.Context) {
	adminID, okA := h.actor(c)
	if !okA {
		return
	}
	id, okP := idParam(c, "id")
	if !okP {
		return
	}
	req, okB := bind[SetPasswordRequest](c)
	if !okB {
		return
	}
	if err := h.service.SetPassword(c.Request.Context(), adminID, id, req); err != nil {
		fail(c, err)
		return
	}
	respond(c, gin.H{"updated": true})
}

/* ---- parent-child links ---- */

func (h *Handler) ListParentLinks(c *gin.Context) {
	parentID, ok1 := queryI64(c, "parentId")
	if !ok1 {
		return
	}
	childID, ok2 := queryI64(c, "childId")
	if !ok2 {
		return
	}
	rows, err := h.service.ListParentLinks(c.Request.Context(), parentID, childID)
	if err != nil {
		fail(c, err)
		return
	}
	respond(c, rows)
}

func (h *Handler) CreateParentLink(c *gin.Context) {
	adminID, okA := h.actor(c)
	if !okA {
		return
	}
	req, okB := bind[CreateParentLinkRequest](c)
	if !okB {
		return
	}
	if err := h.service.CreateParentLink(c.Request.Context(), adminID, req); err != nil {
		fail(c, err)
		return
	}
	created(c, gin.H{"linked": true})
}

func (h *Handler) DeleteParentLink(c *gin.Context) {
	adminID, okA := h.actor(c)
	if !okA {
		return
	}
	pRaw, cRaw := c.Query("parentId"), c.Query("childId")
	parentID, err1 := strconv.ParseInt(pRaw, 10, 64)
	childID, err2 := strconv.ParseInt(cRaw, 10, 64)
	if err1 != nil || err2 != nil || parentID <= 0 || childID <= 0 {
		httpx.Fail(c, httpx.BadRequest("INVALID_QUERY", "parentId and childId query params are required"))
		return
	}
	if err := h.service.DeleteParentLink(c.Request.Context(), adminID, parentID, childID); err != nil {
		fail(c, err)
		return
	}
	respond(c, gin.H{"deleted": true})
}
