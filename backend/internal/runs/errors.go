package runs

import "errors"

var (
	ErrAssignmentNotFound = errors.New("assignment not found or not published")
	ErrNotCodeAssignment  = errors.New("assignment is not a code assignment")
	ErrNoLanguage         = errors.New("this code assignment has no language set")
	ErrNotEnrolled        = errors.New("not enrolled in the course")
	ErrRunnerUnavailable  = errors.New("the code runner is unavailable")
	ErrThrottled          = errors.New("too many runs — slow down")
	ErrNoTests            = errors.New("this assignment has no automated tests")
	ErrTestNotFound       = errors.New("test case not found")
)

// ValidationError carries a user-safe message for a 400.
type ValidationError struct{ Message string }

func (e *ValidationError) Error() string { return e.Message }

func invalid(msg string) error { return &ValidationError{Message: msg} }
