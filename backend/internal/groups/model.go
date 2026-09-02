package groups

import "time"

// Group statuses (see migration 00012's CHECK constraint).
const (
	StatusDraft     = "draft"
	StatusActive    = "active"
	StatusCompleted = "completed"
	StatusCancelled = "cancelled"
)

// Group is the internal representation of a row in the groups table.
type Group struct {
	ID          int64
	CourseID    int64
	TeacherID   int64
	Title       string
	Description *string
	StartDate   *time.Time
	EndDate     *time.Time
	MaxStudents *int
	Status      string
	CreatedAt   time.Time
	UpdatedAt   time.Time
}
