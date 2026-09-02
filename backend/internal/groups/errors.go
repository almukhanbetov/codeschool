package groups

import "errors"

var (
	// ErrGroupNotFound covers both "no such group" and "not this teacher's
	// group" — a teacher never learns which (avoids leaking the existence of
	// another teacher's group).
	ErrGroupNotFound = errors.New("group not found")
	// ErrStudentNotInGroup: the student is not a member of the teacher's
	// group (or the submission's student isn't).
	ErrStudentNotInGroup  = errors.New("student is not in this group")
	ErrSubmissionNotFound = errors.New("submission not found")

	// AddStudent (seed / future admin) errors.
	ErrGroupFull      = errors.New("group is full")
	ErrAlreadyInGroup = errors.New("student is already in this group")
	ErrNotAStudent    = errors.New("user is not a student")
	ErrNotATeacher    = errors.New("user is not a teacher")
)
