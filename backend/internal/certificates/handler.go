package certificates

import (
	"errors"
	"fmt"
	"net/http"
	"strconv"
	"strings"

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

func callerID(c *gin.Context) (int64, bool) {
	id, ok := authctx.UserID(c)
	if !ok {
		httpx.Fail(c, httpx.Unauthorized(httpx.CodeUnauthorized, "Authentication required"))
	}
	return id, ok
}

/* ================= learner ================= */

// Issue handles POST /courses/:id/certificate (and the /teacher-academy
// alias). Lazy + idempotent: returns the existing certificate or creates one
// if the course is genuinely complete. The learner id comes from the token.
func (h *Handler) Issue(c *gin.Context) {
	uid, ok := callerID(c)
	if !ok {
		return
	}
	courseID, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}
	res, err := h.service.Issue(c.Request.Context(), uid, courseID)
	if err != nil {
		httpx.Fail(c, mapErr(err))
		return
	}
	httpx.OK(c, res)
}

// ListMine handles GET /me/certificates.
func (h *Handler) ListMine(c *gin.Context) {
	uid, ok := callerID(c)
	if !ok {
		return
	}
	res, err := h.service.ListMine(c.Request.Context(), uid)
	if err != nil {
		httpx.Fail(c, mapErr(err))
		return
	}
	httpx.OK(c, res)
}

// GetMine handles GET /me/certificates/:id.
func (h *Handler) GetMine(c *gin.Context) {
	uid, ok := callerID(c)
	if !ok {
		return
	}
	id, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}
	res, err := h.service.GetMine(c.Request.Context(), uid, id)
	if err != nil {
		httpx.Fail(c, mapErr(err))
		return
	}
	httpx.OK(c, res)
}

// MyPDF handles GET /me/certificates/:id/pdf?lang=ru|kz|en.
func (h *Handler) MyPDF(c *gin.Context) {
	uid, ok := callerID(c)
	if !ok {
		return
	}
	id, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}
	pdf, cert, err := h.service.PDFForOwner(c.Request.Context(), uid, id, c.Query("lang"))
	if err != nil {
		httpx.Fail(c, mapErr(err))
		return
	}
	writePDF(c, pdf, cert)
}

/* ================= public ================= */

// Verify handles GET /api/v1/certificates/verify/:code (no auth).
func (h *Handler) Verify(c *gin.Context) {
	code := strings.TrimSpace(c.Param("code"))
	if code == "" {
		httpx.Fail(c, httpx.BadRequest(httpx.CodeInvalidRequest, "A verification code is required"))
		return
	}
	res, err := h.service.Verify(c.Request.Context(), code)
	if err != nil {
		if errors.Is(err, ErrNotFound) {
			// Consistent design: unknown code -> 404, no extra detail.
			httpx.Fail(c, httpx.NotFound(httpx.CodeNotFound, "No certificate matches this code"))
			return
		}
		httpx.Fail(c, mapErr(err))
		return
	}
	httpx.OK(c, res)
}

/* ================= admin ================= */

type AdminHandler struct {
	service *Service
}

func NewAdminHandler(service *Service) *AdminHandler {
	return &AdminHandler{service: service}
}

func (h *AdminHandler) List(c *gin.Context) {
	f := AdminListFilter{
		Status: c.Query("status"),
		Query:  c.Query("q"),
		Page:   atoiDefault(c.Query("page"), 1),
		Limit:  atoiDefault(c.Query("limit"), 20),
	}
	if raw := c.Query("course_id"); raw != "" {
		if v, err := strconv.ParseInt(raw, 10, 64); err == nil && v > 0 {
			f.CourseID = &v
		}
	}
	if f.Status != "" && f.Status != StatusActive && f.Status != StatusRevoked {
		httpx.Fail(c, httpx.BadRequest(httpx.CodeInvalidRequest, "status must be active or revoked"))
		return
	}
	res, err := h.service.AdminList(c.Request.Context(), f)
	if err != nil {
		httpx.Fail(c, mapErr(err))
		return
	}
	httpx.OK(c, res)
}

func (h *AdminHandler) Get(c *gin.Context) {
	id, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}
	res, err := h.service.AdminGet(c.Request.Context(), id)
	if err != nil {
		httpx.Fail(c, mapErr(err))
		return
	}
	httpx.OK(c, res)
}

func (h *AdminHandler) PDF(c *gin.Context) {
	id, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}
	pdf, cert, err := h.service.PDFForAdmin(c.Request.Context(), id, c.Query("lang"))
	if err != nil {
		httpx.Fail(c, mapErr(err))
		return
	}
	writePDF(c, pdf, cert)
}

func (h *AdminHandler) Revoke(c *gin.Context) {
	adminID, ok := authctx.UserID(c)
	if !ok {
		httpx.Fail(c, httpx.Unauthorized(httpx.CodeUnauthorized, "Authentication required"))
		return
	}
	id, ok := httpx.ParseIDParam(c, "id")
	if !ok {
		return
	}
	var req RevokeRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		httpx.Fail(c, httpx.BadRequest(httpx.CodeInvalidRequest, "Invalid request body"))
		return
	}
	res, err := h.service.Revoke(c.Request.Context(), adminID, id, req)
	if err != nil {
		httpx.Fail(c, mapErr(err))
		return
	}
	httpx.OK(c, res)
}

/* ================= helpers ================= */

func writePDF(c *gin.Context, pdf []byte, cert Certificate) {
	filename := fmt.Sprintf("certificate-%s.pdf", strings.ToLower(strings.ReplaceAll(cert.CertificateNumber, " ", "-")))
	c.Header("Content-Disposition", fmt.Sprintf("attachment; filename=%q", filename))
	c.Data(http.StatusOK, "application/pdf", pdf)
}

func atoiDefault(s string, def int) int {
	if v, err := strconv.Atoi(strings.TrimSpace(s)); err == nil {
		return v
	}
	return def
}

func mapErr(err error) error {
	switch {
	case err == nil:
		return nil
	case errors.Is(err, ErrNotFound):
		return httpx.NotFound(httpx.CodeNotFound, "Certificate not found")
	case errors.Is(err, ErrNotEnrolled):
		return httpx.Conflict(httpx.CodeConflict, "You are not enrolled in this course")
	case errors.Is(err, ErrNotEligible):
		return httpx.Conflict(httpx.CodeConflict, "This course is not completed yet")
	case errors.Is(err, ErrReasonRequired):
		return httpx.BadRequest(httpx.CodeInvalidRequest, "A revoke reason is required")
	case errors.Is(err, ErrAlreadyRevoked):
		return httpx.Conflict(httpx.CodeConflict, "This certificate is already revoked")
	case errors.Is(err, ErrForbidden):
		return httpx.NotFound(httpx.CodeNotFound, "Certificate not found")
	case errors.Is(err, ErrIssueRetriesExhausted):
		return httpx.Internal("Could not issue the certificate, please retry")
	default:
		return err
	}
}
