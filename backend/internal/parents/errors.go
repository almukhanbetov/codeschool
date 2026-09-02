package parents

import "errors"

var (
	// ErrChildNotFound covers "no such user" and "not linked to this parent"
	// alike — a parent never learns whether an unrelated student exists.
	ErrChildNotFound = errors.New("child not found")
	// ErrCourseNotFound: the child is not enrolled in that course.
	ErrCourseNotFound = errors.New("course not found for this child")
)
