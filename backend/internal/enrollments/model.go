package enrollments

import "time"

// Enrollment statuses. A student has at most one 'active' row per course
// (enforced by a partial unique index in migration 00008).
const (
	StatusActive    = "active"
	StatusCompleted = "completed"
	StatusCancelled = "cancelled"
)

// Enrollment is the internal representation of a row in the enrollments table.
type Enrollment struct {
	ID          int64
	StudentID   int64
	CourseID    int64
	Status      string
	EnrolledAt  time.Time
	CompletedAt *time.Time
	CreatedAt   time.Time
	UpdatedAt   time.Time
}
