package auth

import "errors"

// Domain errors. The handler is the only place these become HTTP responses
// (see errorStatus in handler.go); the service and middleware only ever
// return these values, never *httpx.APIError.
// ValidationError is a user-safe 400: a bad field value the client can fix.
// Its message is shown to the client verbatim.
type ValidationError struct{ Message string }

func (e *ValidationError) Error() string { return e.Message }

func validationError(msg string) error { return &ValidationError{Message: msg} }

var (
	ErrInvalidCredentials  = errors.New("invalid credentials")
	ErrUserInactive        = errors.New("user account is inactive")
	ErrDuplicateEmail      = errors.New("email already registered")
	ErrDuplicatePhone      = errors.New("phone already registered")
	ErrInvalidRefreshToken = errors.New("invalid or expired refresh token")
	ErrUnauthorized        = errors.New("authentication required")
	ErrForbidden           = errors.New("insufficient permissions")
)
