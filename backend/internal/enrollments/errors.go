package enrollments

import "errors"

var (
	ErrNotFound           = errors.New("enrollment not found")
	ErrAlreadyEnrolled    = errors.New("already enrolled in this course")
	ErrCourseNotAvailable = errors.New("course does not exist or is not published")
)
