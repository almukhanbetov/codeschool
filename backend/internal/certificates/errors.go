package certificates

import "errors"

var (
	// ErrNotFound — no such certificate (by id, code, or owner scope).
	ErrNotFound = errors.New("certificate not found")
	// ErrNotEnrolled — the learner has no enrollment for the course.
	ErrNotEnrolled = errors.New("not enrolled in this course")
	// ErrNotEligible — the course is not yet fully completed.
	ErrNotEligible = errors.New("course is not completed")
	// ErrForbidden — the caller is not the certificate's owner.
	ErrForbidden = errors.New("not the certificate owner")
	// ErrReasonRequired — revoke called without a non-empty reason.
	ErrReasonRequired = errors.New("a revoke reason is required")
	// ErrAlreadyRevoked — revoke called on an already-revoked certificate.
	ErrAlreadyRevoked = errors.New("certificate is already revoked")
	// ErrIssueRetriesExhausted — could not find a free number/code.
	ErrIssueRetriesExhausted = errors.New("could not allocate a unique certificate number")

	// internal sentinels returned by the repository Insert to let the
	// service decide between "return the existing one" and "retry".
	errUserCourseConflict   = errors.New("certificate already exists for this user+course")
	errNumberOrCodeConflict = errors.New("certificate number or verification code collision")
)
