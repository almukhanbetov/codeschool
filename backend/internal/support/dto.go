package support

import "time"

/* ================= requests ================= */

// CreateThreadRequest — POST /support/threads. The client never sends
// user_id / student_id / sender_role; the server derives identity from the
// JWT. `studentId` is only read for a parent (must be a linked child).
type CreateThreadRequest struct {
	Subject      string `json:"subject"`
	Category     string `json:"category"`
	CourseID     *int64 `json:"courseId"`
	LessonID     *int64 `json:"lessonId"`
	AssignmentID *int64 `json:"assignmentId"`
	StudentID    *int64 `json:"studentId"` // parent only
	Message      string `json:"message"`
}

// CreateMessageRequest — POST /support/threads/:id/messages (and the admin
// variant, which additionally honours `internal`).
type CreateMessageRequest struct {
	Body     string `json:"body"`
	Internal bool   `json:"internal"` // admin only; ignored for students/parents
}

// AssignRequest — POST /admin/support/threads/:id/assign. Null / omitted
// adminId un-assigns.
type AssignRequest struct {
	AdminID *int64 `json:"adminId"`
}

// StatusRequest — POST /admin/support/threads/:id/status.
type StatusRequest struct {
	Status string `json:"status"`
}

/* ================= responses ================= */

type ThreadAbout struct {
	StudentName    string  `json:"studentName"`
	CourseTitle    *string `json:"courseTitle,omitempty"`
	LessonTitle    *string `json:"lessonTitle,omitempty"`
	AssignmentName *string `json:"assignmentName,omitempty"`
}

// ThreadListItem — one row of GET /support/threads.
type ThreadListItem struct {
	ID              int64       `json:"id"`
	Subject         string      `json:"subject"`
	Category        string      `json:"category"`
	Status          string      `json:"status"`
	Priority        string      `json:"priority"`
	About           ThreadAbout `json:"about"`
	LastMessage     string      `json:"lastMessagePreview"`
	LastMessageAt   time.Time   `json:"lastMessageAt"`
	UnreadCount     int         `json:"unreadCount"`
	AssignedToStaff bool        `json:"assignedToStaff"`
	CreatedAt       time.Time   `json:"createdAt"`
}

// ThreadDetail — GET /support/threads/:id (messages come from the messages
// endpoint).
type ThreadDetail struct {
	ThreadListItem
	IsParentThread bool `json:"isParentThread"`
}

// MessageDTO — one message as a student/parent (or admin) sees it. Internal
// notes are never included in a student/parent payload.
type MessageDTO struct {
	ID          int64      `json:"id"`
	Body        string     `json:"body"`
	MessageType string     `json:"messageType"`
	SenderRole  string     `json:"senderRole"`
	SenderName  string     `json:"senderName"`
	Mine        bool       `json:"mine"`
	IsInternal  bool       `json:"isInternal"`
	CreatedAt   time.Time  `json:"createdAt"`
	EditedAt    *time.Time `json:"editedAt,omitempty"`
}

// UnreadCountDTO — GET /support/unread-count and the admin variant.
type UnreadCountDTO struct {
	Threads  int `json:"threads"`  // threads with ≥1 unread
	Messages int `json:"messages"` // total unread messages
}

/* ================= admin ================= */

type PersonRef struct {
	ID    int64   `json:"id"`
	Name  string  `json:"name"`
	Email *string `json:"email,omitempty"`
}

// AdminThreadListItem — one row of GET /admin/support/threads.
type AdminThreadListItem struct {
	ID            int64      `json:"id"`
	Kind          string     `json:"kind"` // "student" | "parent"
	Owner         PersonRef  `json:"owner"`
	StudentName   string     `json:"studentName"`
	Subject       string     `json:"subject"`
	Category      string     `json:"category"`
	Status        string     `json:"status"`
	Priority      string     `json:"priority"`
	CourseTitle   *string    `json:"courseTitle,omitempty"`
	AssignedAdmin *PersonRef `json:"assignedAdmin,omitempty"`
	LastMessage   string     `json:"lastMessagePreview"`
	LastMessageAt time.Time  `json:"lastMessageAt"`
	UnreadCount   int        `json:"unreadCount"`
	CreatedAt     time.Time  `json:"createdAt"`
}

// AdminThreadDetail — GET /admin/support/threads/:id.
type AdminThreadDetail struct {
	AdminThreadListItem
	LessonTitle    *string         `json:"lessonTitle,omitempty"`
	AssignmentName *string         `json:"assignmentName,omitempty"`
	Context        LearningContext `json:"context"`
}

/* ---- learning context (read-only, read live from LMS state) ---- */

type ContextCourse struct {
	ID               int64  `json:"id"`
	Title            string `json:"title"`
	Slug             string `json:"slug"`
	EnrollmentStatus string `json:"enrollmentStatus"`
	CompletedLessons int    `json:"completedLessons"`
	TotalLessons     int    `json:"totalLessons"`
	ProgressPercent  int    `json:"progressPercent"`
	IsFocus          bool   `json:"isFocus"` // the course this thread is about
}

type ContextQuiz struct {
	AssignmentTitle string `json:"assignmentTitle"`
	Attempts        int    `json:"attempts"`
	LatestPercent   *int   `json:"latestPercent,omitempty"`
	PassPercent     int    `json:"passPercent"`
	Passed          bool   `json:"passed"`
}

type ContextSubmission struct {
	AssignmentTitle string `json:"assignmentTitle"`
	AssignmentType  string `json:"assignmentType"`
	Status          string `json:"status"`
	Score           *int   `json:"score,omitempty"`
	SubmissionID    int64  `json:"submissionId"`
}

type ContextCodeRun struct {
	AssignmentTitle string    `json:"assignmentTitle"`
	Language        string    `json:"language"`
	Status          string    `json:"status"`
	Kind            string    `json:"kind"`
	At              time.Time `json:"at"`
}

type ContextCertificate struct {
	Eligible          bool    `json:"eligible"`
	Issued            bool    `json:"issued"`
	CertificateNumber *string `json:"certificateNumber,omitempty"`
	Status            *string `json:"status,omitempty"`
}

// LearningContext is the manager's right-hand panel. Everything here is read
// from the current LMS tables on request — nothing is copied into the chat.
type LearningContext struct {
	Student          PersonRef           `json:"student"`
	Parent           *PersonRef          `json:"parent,omitempty"`
	ParentLinked     *bool               `json:"parentLinked,omitempty"`
	Courses          []ContextCourse     `json:"courses"`
	FocusCourse      *ContextCourse      `json:"focusCourse,omitempty"`
	CurrentLesson    *string             `json:"currentLesson,omitempty"`
	LatestQuiz       *ContextQuiz        `json:"latestQuiz,omitempty"`
	LatestSubmission *ContextSubmission  `json:"latestSubmission,omitempty"`
	LatestCodeRun    *ContextCodeRun     `json:"latestCodeRun,omitempty"`
	Certificate      *ContextCertificate `json:"certificate,omitempty"`
}
