package users

import "errors"

var (
	// ErrNotFound is returned by the repository when no user matches.
	ErrNotFound = errors.New("user not found")
	// ErrDuplicateEmail / ErrDuplicatePhone are returned by CreateUser when a
	// partial unique index rejects the insert.
	ErrDuplicateEmail = errors.New("email already registered")
	ErrDuplicatePhone = errors.New("phone already registered")
)
