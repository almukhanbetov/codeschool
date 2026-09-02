package assignments

import "errors"

var (
	ErrNotFound       = errors.New("assignment not found")
	ErrLessonNotFound = errors.New("lesson not found or not published")
	ErrNotEnrolled    = errors.New("not enrolled in the course that owns this lesson")
)
