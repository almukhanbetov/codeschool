package auth

import "codeschool/backend/internal/users"

// RegisterRequest is the POST /auth/register body. Either email or phone
// must be present (validated in the service, not just by binding tags).
type RegisterRequest struct {
	Email     *string `json:"email"`
	Phone     *string `json:"phone"`
	Password  string  `json:"password" binding:"required"`
	FirstName string  `json:"firstName" binding:"required"`
	LastName  *string `json:"lastName"`
	Role      string  `json:"role" binding:"required"`
}

// LoginRequest is the POST /auth/login body. Exactly one of email / phone
// identifies the account.
type LoginRequest struct {
	Email    *string `json:"email"`
	Phone    *string `json:"phone"`
	Password string  `json:"password" binding:"required"`
}

// RefreshRequest / LogoutRequest carry an optional refreshToken in the body.
// The HttpOnly cookie is the primary source; the body is a fallback for
// non-browser clients (curl, tests).
type RefreshRequest struct {
	RefreshToken *string `json:"refreshToken"`
}

type LogoutRequest struct {
	RefreshToken *string `json:"refreshToken"`
}

// LoginResult is what the service returns for a successful login/refresh. The
// handler turns the access token into JSON and the refresh token into an
// HttpOnly cookie — the plain refresh token never appears in the response
// body.
type LoginResult struct {
	AccessToken     string
	ExpiresInSecs   int
	RefreshToken    string // plain — set as a cookie by the handler, not serialized
	RefreshTokenTTL int    // seconds, for the cookie Max-Age
	User            users.User
}

// AccessResponse is the JSON body for login and refresh.
type AccessResponse struct {
	AccessToken string          `json:"accessToken"`
	ExpiresIn   int             `json:"expiresIn"`
	User        *users.Response `json:"user,omitempty"`
}
