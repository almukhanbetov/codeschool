// Package admin implements the admin panel API: full CRUD over users, the
// catalog (programs → levels → courses → modules → lessons → assignments),
// groups (+ teacher assignment + membership) and parent-child links, plus a
// read-only audit log. Every route requires role = admin.
package admin

import "errors"

var (
	ErrNotFound   = errors.New("resource not found")
	ErrConflict   = errors.New("resource conflict (duplicate key)")
	ErrInUse      = errors.New("resource is referenced by other records")
	ErrValidation = errors.New("validation failed")

	// user-specific guards
	ErrLastAdmin      = errors.New("cannot remove the last active admin")
	ErrSelfMutation   = errors.New("an admin cannot delete or deactivate their own account")
	ErrRoleMismatch   = errors.New("the target user does not have the required role")
	ErrDuplicateEmail = errors.New("email already in use")
	ErrDuplicatePhone = errors.New("phone already in use")
)

// ValidationError carries a user-safe message for a 400.
type ValidationError struct{ Message string }

func (e *ValidationError) Error() string { return e.Message }

func invalid(msg string) error { return &ValidationError{Message: msg} }
