package submissions

import "time"

// Submission statuses.
//
//	draft      → student is still working (editable)
//	submitted  → sent to the teacher, waiting in the review queue (locked)
//	checking   → a teacher has opened it for review (locked)
//	passed     → review complete, accepted (locked)
//	failed     → review complete, needs revision (EDITABLE again — the student
//	             revises and resubmits, which clears the old score/feedback)
const (
	StatusDraft     = "draft"
	StatusSubmitted = "submitted"
	StatusChecking  = "checking"
	StatusPassed    = "passed"
	StatusFailed    = "failed"
)

// editableStatuses are the states from which a student may edit / (re)submit.
func isEditable(status string) bool {
	return status == StatusDraft || status == StatusFailed
}

// Submission is the internal representation of a row in the submissions table.
// There is one current row per (student, assignment) — no attempt history yet.
type Submission struct {
	ID              int64
	AssignmentID    int64
	StudentID       int64
	Code            *string
	Answer          *string
	Status          string
	Score           *int
	TeacherFeedback *string
	SubmittedAt     *time.Time
	CheckedAt       *time.Time
	CreatedAt       time.Time
	UpdatedAt       time.Time
}
