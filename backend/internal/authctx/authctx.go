// Package authctx is the tiny shared vocabulary for passing the
// authenticated caller's identity through the Gin context. It has no
// dependencies on the auth or users packages, so any handler can read the
// current user without creating an import cycle.
package authctx

import "github.com/gin-gonic/gin"

const (
	keyUserID = "auth_user_id"
	keyRole   = "auth_user_role"
)

// Set stores the authenticated user's id and role on the context. Called by
// the auth middleware after it validates the access token.
func Set(c *gin.Context, userID int64, role string) {
	c.Set(keyUserID, userID)
	c.Set(keyRole, role)
}

// UserID returns the authenticated user's id, or (0, false) if the request
// did not pass through the auth middleware.
func UserID(c *gin.Context) (int64, bool) {
	v, ok := c.Get(keyUserID)
	if !ok {
		return 0, false
	}
	id, ok := v.(int64)
	return id, ok
}

// Role returns the authenticated user's role, or ("", false).
func Role(c *gin.Context) (string, bool) {
	v, ok := c.Get(keyRole)
	if !ok {
		return "", false
	}
	role, ok := v.(string)
	return role, ok
}
