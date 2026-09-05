package support

import "time"

// Thread status lifecycle (see migration 00027 CHECK):
//
//	open          — created, no staff reply yet
//	waiting_staff  — user posted, staff's turn
//	waiting_user   — staff replied, user's turn
//	closed         — resolved. A user posting to a closed thread auto-reopens
//	                 it to waiting_staff (documented rule).
const (
	StatusOpen         = "open"
	StatusWaitingStaff = "waiting_staff"
	StatusWaitingUser  = "waiting_user"
	StatusClosed       = "closed"
)

const (
	PriorityNormal = "normal"
	PriorityHigh   = "high"
)

// Categories — extend the CHECK constraint + this list together.
var Categories = []string{
	"general", "course", "lesson", "assignment", "quiz", "code_runner",
	"progress", "certificate", "account", "parent_question", "technical",
}

// Message types.
const (
	MsgText             = "text"
	MsgSystem           = "system"
	MsgStaffNoteVisible = "staff_note_visible"
	MsgInternalNote     = "internal_note"
	MsgLearningContext  = "learning_context"
)

// MaxMessageLen is the hard server-side cap (spec §30).
const MaxMessageLen = 4000

// Thread is a row of support_threads.
type Thread struct {
	ID              int64
	UserID          int64
	StudentID       *int64
	CourseID        *int64
	LessonID        *int64
	AssignmentID    *int64
	Subject         string
	Category        string
	Status          string
	Priority        string
	AssignedAdminID *int64
	CreatedAt       time.Time
	UpdatedAt       time.Time
	LastMessageAt   time.Time
	ClosedAt        *time.Time
}

// Message is a row of support_messages.
type Message struct {
	ID           int64
	ThreadID     int64
	SenderUserID int64
	SenderRole   string
	Body         string
	MessageType  string
	IsInternal   bool
	CreatedAt    time.Time
	EditedAt     *time.Time
	DeletedAt    *time.Time
}

// NewThreadInput is the validated, identity-resolved payload the service
// hands the repository. The client never sets user_id / student_id directly.
type NewThreadInput struct {
	UserID       int64
	StudentID    int64
	CourseID     *int64
	LessonID     *int64
	AssignmentID *int64
	Subject      string
	Category     string
	FirstMessage string
}

func validCategory(c string) bool {
	for _, v := range Categories {
		if v == c {
			return true
		}
	}
	return false
}

func validStatus(s string) bool {
	switch s {
	case StatusOpen, StatusWaitingStaff, StatusWaitingUser, StatusClosed:
		return true
	}
	return false
}
