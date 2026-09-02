package submissions

import "errors"

var (
	ErrNotFound           = errors.New("submission not found")
	ErrAssignmentNotFound = errors.New("assignment not found or not published")
	ErrNotEnrolled        = errors.New("not enrolled in the course that owns this assignment")
	// ErrLocked: the submission is in a state a student may not edit
	// (submitted / checking / passed). A 'failed' submission IS editable so
	// the student can revise and resubmit.
	ErrLocked          = errors.New("this submission cannot be edited right now")
	ErrNothingToSubmit = errors.New("save a draft before submitting")

	// Teacher review errors.
	ErrNotReviewable       = errors.New("submission is not awaiting review")
	ErrInvalidReviewStatus = errors.New("review status must be 'passed' or 'failed'")
	ErrScoreOutOfRange     = errors.New("score is outside the assignment's points range")
	ErrScoreRequired       = errors.New("a score is required for this assignment")
	ErrFeedbackRequired    = errors.New("feedback is required when marking a submission failed")
)
