package progress

import "time"

// lesson_progress statuses (see migration 00010's CHECK constraint).
const (
	StatusNotStarted = "not_started"
	StatusInProgress = "in_progress"
	StatusCompleted  = "completed"
)

// LessonProgress is the internal representation of a row in lesson_progress.
type LessonProgress struct {
	ID              int64
	StudentID       int64
	LessonID        int64
	Status          string
	ProgressPercent int
	StartedAt       *time.Time
	CompletedAt     *time.Time
	CreatedAt       time.Time
	UpdatedAt       time.Time
}

// CourseCounts is the completed/total published-lesson tally for one course.
type CourseCounts struct {
	CourseID         int64
	Title            string
	CompletedLessons int
	TotalLessons     int
}

// Percent is completed/total as a 0–100 integer, guarding against division
// by zero.
func (c CourseCounts) Percent() int {
	if c.TotalLessons <= 0 {
		return 0
	}
	return int(float64(c.CompletedLessons) / float64(c.TotalLessons) * 100)
}

// CompleteResult is what CompleteLessonTx returns: the lesson row plus the
// recalculated course tally and whether the enrollment just auto-completed.
type CompleteResult struct {
	Lesson              LessonProgress
	Course              CourseCounts
	EnrollmentCompleted bool
}
