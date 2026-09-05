package support

import "errors"

var (
	// ErrThreadNotFound — no such thread, or not visible to this caller.
	ErrThreadNotFound = errors.New("support thread not found")
	// ErrForbiddenChild — a parent referenced a student who is not their child.
	ErrForbiddenChild = errors.New("student is not a linked child")
	// ErrCourseAccess — the referenced course/lesson/assignment is not one the
	// student has access to.
	ErrCourseAccess = errors.New("no access to the referenced course")
	// ErrInvalidCategory — category outside the allowed set.
	ErrInvalidCategory = errors.New("invalid category")
	// ErrInvalidStatus — status outside the allowed set.
	ErrInvalidStatus = errors.New("invalid status")
	// ErrEmptyMessage — a message with no usable text.
	ErrEmptyMessage = errors.New("message body is required")
	// ErrMessageTooLong — message over the 4000-char cap.
	ErrMessageTooLong = errors.New("message is too long")
	// ErrSubjectRequired — thread created without a subject.
	ErrSubjectRequired = errors.New("a subject is required")
	// ErrThreadClosedForStaffOnly — an action only valid on an open thread.
	ErrThreadClosed = errors.New("thread is closed")
	// ErrNotAnAdmin — assign target is not an admin.
	ErrNotAnAdmin = errors.New("assignee must be an admin")
)
