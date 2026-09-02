package assignments

import "time"

// Allowed assignment_type values (see migration 00009's CHECK constraint).
const (
	TypeText    = "text"
	TypeCode    = "code"
	TypeQuiz    = "quiz"
	TypeProject = "project"
)

// Assignment is the internal representation of a row in the assignments table.
type Assignment struct {
	ID             int64
	LessonID       int64
	Title          string
	Description    *string
	AssignmentType string
	StarterCode    *string
	ExpectedOutput *string
	Points         int
	Position       int
	IsPublished    bool
	CreatedAt      time.Time
	UpdatedAt      time.Time
}
