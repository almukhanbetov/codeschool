package auth

import (
	"errors"
	"net/http"

	"github.com/gin-gonic/gin"

	"codeschool/backend/internal/httpx"
	"codeschool/backend/internal/users"
)

// refreshCookieName is the HttpOnly cookie carrying the refresh token. Its
// Path is scoped to the auth routes so it is only sent where it is needed.
const (
	refreshCookieName = "refresh_token"
	refreshCookiePath = "/api/v1/auth"
)

type Handler struct {
	service      *Service
	cookieSecure bool
}

// NewHandler builds the auth HTTP handler. cookieSecure should be true in
// production (HTTPS) and false for plain-HTTP local development, otherwise
// the browser silently drops the cookie.
func NewHandler(service *Service, cookieSecure bool) *Handler {
	return &Handler{service: service, cookieSecure: cookieSecure}
}

func (h *Handler) Register(c *gin.Context) {
	var req RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		httpx.Fail(c, httpx.BadRequest(httpx.CodeInvalidRequest, "Invalid request body"))
		return
	}

	u, err := h.service.Register(c.Request.Context(), req)
	if err != nil {
		httpx.Fail(c, toAPIError(err))
		return
	}
	httpx.Created(c, users.ToResponse(u))
}

func (h *Handler) Login(c *gin.Context) {
	var req LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		httpx.Fail(c, httpx.BadRequest(httpx.CodeInvalidRequest, "Invalid request body"))
		return
	}

	result, err := h.service.Login(c.Request.Context(), req)
	if err != nil {
		httpx.Fail(c, toAPIError(err))
		return
	}

	h.setRefreshCookie(c, result.RefreshToken, result.RefreshTokenTTL)
	resp := users.ToResponse(result.User)
	httpx.OK(c, AccessResponse{
		AccessToken: result.AccessToken,
		ExpiresIn:   result.ExpiresInSecs,
		User:        &resp,
	})
}

func (h *Handler) Refresh(c *gin.Context) {
	token := h.readRefreshToken(c)

	result, err := h.service.Refresh(c.Request.Context(), token)
	if err != nil {
		httpx.Fail(c, toAPIError(err))
		return
	}

	h.setRefreshCookie(c, result.RefreshToken, result.RefreshTokenTTL)
	httpx.OK(c, AccessResponse{
		AccessToken: result.AccessToken,
		ExpiresIn:   result.ExpiresInSecs,
	})
}

func (h *Handler) Logout(c *gin.Context) {
	token := h.readRefreshToken(c)

	if err := h.service.Logout(c.Request.Context(), token); err != nil {
		httpx.Fail(c, toAPIError(err))
		return
	}

	h.clearRefreshCookie(c)
	httpx.OK(c, gin.H{"message": "logged out"})
}

// readRefreshToken prefers the HttpOnly cookie, falling back to a
// refreshToken field in the JSON body for non-browser clients.
func (h *Handler) readRefreshToken(c *gin.Context) string {
	if cookie, err := c.Cookie(refreshCookieName); err == nil && cookie != "" {
		return cookie
	}
	var body RefreshRequest
	if err := c.ShouldBindJSON(&body); err == nil && body.RefreshToken != nil {
		return *body.RefreshToken
	}
	return ""
}

func (h *Handler) setRefreshCookie(c *gin.Context, token string, maxAgeSecs int) {
	c.SetSameSite(http.SameSiteLaxMode)
	c.SetCookie(refreshCookieName, token, maxAgeSecs, refreshCookiePath, "", h.cookieSecure, true)
}

func (h *Handler) clearRefreshCookie(c *gin.Context) {
	c.SetSameSite(http.SameSiteLaxMode)
	c.SetCookie(refreshCookieName, "", -1, refreshCookiePath, "", h.cookieSecure, true)
}

// toAPIError maps an auth domain error to the shared HTTP error envelope.
// Anything unrecognized falls through to httpx.Fail's generic 500.
func toAPIError(err error) error {
	var ve *ValidationError
	if errors.As(err, &ve) {
		return httpx.BadRequest(httpx.CodeInvalidRequest, ve.Message)
	}
	switch {
	case errors.Is(err, ErrInvalidCredentials):
		return httpx.Unauthorized(httpx.CodeUnauthorized, "Invalid credentials")
	case errors.Is(err, ErrInvalidRefreshToken):
		return httpx.Unauthorized(httpx.CodeUnauthorized, "Invalid or expired refresh token")
	case errors.Is(err, ErrUnauthorized):
		return httpx.Unauthorized(httpx.CodeUnauthorized, "Authentication required")
	case errors.Is(err, ErrUserInactive):
		return httpx.Forbidden(httpx.CodeForbidden, "Account is inactive")
	case errors.Is(err, ErrForbidden):
		return httpx.Forbidden(httpx.CodeForbidden, "Insufficient permissions")
	case errors.Is(err, ErrDuplicateEmail):
		return httpx.Conflict(httpx.CodeConflict, "Email already registered")
	case errors.Is(err, ErrDuplicatePhone):
		return httpx.Conflict(httpx.CodeConflict, "Phone already registered")
	default:
		return err
	}
}
