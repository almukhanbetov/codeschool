package progress

import "errors"

var (
	ErrLessonNotFound       = errors.New("lesson not found or not published")
	ErrNotEnrolled          = errors.New("not enrolled in the course that owns this lesson")
	ErrAssignmentIncomplete = errors.New("submit the lesson's assignment before completing it")
)
