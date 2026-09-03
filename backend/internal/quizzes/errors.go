package quizzes

import "errors"

var (
	// authoring / lookup
	ErrQuizNotFound      = errors.New("quiz not found")
	ErrNotQuizAssignment = errors.New("assignment is not a quiz")
	ErrQuestionNotFound  = errors.New("question not found")
	ErrOptionNotFound    = errors.New("option not found")

	// attempts
	ErrNotEnrolled       = errors.New("not enrolled in the course")
	ErrNoQuestions       = errors.New("quiz has no questions yet")
	ErrQuizMisconfigured = errors.New("quiz is not fully configured")
	ErrMaxAttempts       = errors.New("no attempts remaining")
	ErrAttemptNotFound   = errors.New("attempt not found")
	ErrAttemptNotOwned   = errors.New("attempt belongs to another student")
	ErrAttemptClosed     = errors.New("attempt already submitted")
)

// ValidationError carries a user-safe message for a 400.
type ValidationError struct{ Message string }

func (e *ValidationError) Error() string { return e.Message }

func invalid(msg string) error { return &ValidationError{Message: msg} }
