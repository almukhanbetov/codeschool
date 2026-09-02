package lessons

import "time"

// Lesson is the internal representation of a row in the lessons table.
type Lesson struct {
	ID          int64
	ModuleID    int64
	Title       string
	Slug        *string
	Description *string
	Content     *string
	VideoURL    *string
	LessonType  string
	Position    int
	IsPublished bool
	CreatedAt   time.Time
	UpdatedAt   time.Time
}

// Allowed lesson_type values (application-level validation only — see
// migration 00005, no DB enum for now).
const (
	TypeText    = "text"
	TypeVideo   = "video"
	TypeCode    = "code"
	TypeQuiz    = "quiz"
	TypeProject = "project"
)
