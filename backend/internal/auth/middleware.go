package auth

import (
	"context"
	"strings"

	"github.com/gin-gonic/gin"

	"codeschool/backend/internal/authctx"
	"codeschool/backend/internal/httpx"
	"codeschool/backend/internal/users"
)

// activeChecker is the one thing the middleware needs from users: confirm the
// account behind a valid token is still active (spec: inactive users must not
// reach protected endpoints even with a non-expired access token).
type activeChecker interface {
	FindByID(ctx context.Context, id int64) (users.User, error)
}

// Middleware validates the "Authorization: Bearer <token>" header. On success
// it stores the user id and role on the Gin context (see authctx) for
// downstream handlers and RequireRole. On any failure it aborts with 401.
func Middleware(tm *TokenManager, checker activeChecker) gin.HandlerFunc {
	return func(c *gin.Context) {
		raw := c.GetHeader("Authorization")
		token, ok := bearerToken(raw)
		if !ok {
			httpx.Fail(c, httpx.Unauthorized(httpx.CodeUnauthorized, "Authentication required"))
			c.Abort()
			return
		}

		userID, role, err := tm.ParseAccessToken(token)
		if err != nil {
			httpx.Fail(c, httpx.Unauthorized(httpx.CodeUnauthorized, "Invalid or expired token"))
			c.Abort()
			return
		}

		u, err := checker.FindByID(c.Request.Context(), userID)
		if err != nil || !u.IsActive {
			httpx.Fail(c, httpx.Unauthorized(httpx.CodeUnauthorized, "Account is not available"))
			c.Abort()
			return
		}

		authctx.Set(c, userID, role)
		c.Next()
	}
}

// RequireRole aborts with 403 unless the authenticated user's role is exactly
// one of the allowed roles. It must run after Middleware.
func RequireRole(allowed ...string) gin.HandlerFunc {
	return func(c *gin.Context) {
		role, ok := authctx.Role(c)
		if !ok {
			httpx.Fail(c, httpx.Unauthorized(httpx.CodeUnauthorized, "Authentication required"))
			c.Abort()
			return
		}
		for _, a := range allowed {
			if role == a {
				c.Next()
				return
			}
		}
		httpx.Fail(c, httpx.Forbidden(httpx.CodeForbidden, "Insufficient permissions"))
		c.Abort()
	}
}

// RequireAnyRole is an alias spelling for RequireRole, kept because the spec
// names both.
func RequireAnyRole(allowed ...string) gin.HandlerFunc {
	return RequireRole(allowed...)
}

// bearerToken extracts the token from an "Authorization: Bearer x" header.
func bearerToken(header string) (string, bool) {
	const prefix = "Bearer "
	if len(header) <= len(prefix) || !strings.EqualFold(header[:len(prefix)], prefix) {
		return "", false
	}
	token := strings.TrimSpace(header[len(prefix):])
	if token == "" {
		return "", false
	}
	return token, true
}
