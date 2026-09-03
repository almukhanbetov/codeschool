package groups

import "time"

// CourseBrief is the trimmed course shape embedded in group responses.
type CourseBrief struct {
	ID    int64  `json:"id"`
	Title string `json:"title"`
	Slug  string `json:"slug"`
}

// StudentBrief is the trimmed, safe student shape — never a password hash,
// tokens, or contact details.
type StudentBrief struct {
	ID        int64   `json:"id"`
	FirstName string  `json:"firstName"`
	LastName  *string `json:"lastName"`
}

// ProgressBrief is the completed/total lesson tally for a student in a course.
type ProgressBrief struct {
	CompletedLessons int `json:"completedLessons"`
	TotalLessons     int `json:"totalLessons"`
	ProgressPercent  int `json:"progressPercent"`
}

// Dashboard is GET /teacher/dashboard.
type Dashboard struct {
	GroupsCount         int `json:"groupsCount"`
	StudentsCount       int `json:"studentsCount"`
	PendingSubmissions  int `json:"pendingSubmissions"`
	ReviewedSubmissions int `json:"reviewedSubmissions"`
}

// GroupListItem is one row of GET /teacher/groups.
type GroupListItem struct {
	ID             int64       `json:"id"`
	Title          string      `json:"title"`
	Status         string      `json:"status"`
	StudentCount   int         `json:"studentCount"`
	AvgProgressPct int         `json:"avgProgressPercent"`
	StartDate      *time.Time  `json:"startDate"`
	Course         CourseBrief `json:"course"`
}

// GroupDetail is GET /teacher/groups/:id.
type GroupDetail struct {
	GroupListItem
	Description *string    `json:"description"`
	EndDate     *time.Time `json:"endDate"`
	MaxStudents *int       `json:"maxStudents"`
}

// GroupStudentItem is one row of GET /teacher/groups/:id/students.
type GroupStudentItem struct {
	Student            StudentBrief  `json:"student"`
	Progress           ProgressBrief `json:"progress"`
	PendingSubmissions int           `json:"pendingSubmissions"`
	JoinedAt           time.Time     `json:"joinedAt"`
}

// LessonProgressItem is one lesson's status in the student-detail view.
type LessonProgressItem struct {
	LessonID    int64      `json:"lessonId"`
	Title       string     `json:"title"`
	Status      string     `json:"status"`
	CompletedAt *time.Time `json:"completedAt"`
}

// SubmissionSummaryItem is one assignment's submission state in the
// student-detail view.
type SubmissionSummaryItem struct {
	SubmissionID    *int64     `json:"submissionId"`
	AssignmentID    int64      `json:"assignmentId"`
	AssignmentTitle string     `json:"assignmentTitle"`
	LessonTitle     string     `json:"lessonTitle"`
	Points          int        `json:"points"`
	Status          string     `json:"status"` // "" when the student has no submission
	Score           *int       `json:"score"`
	SubmittedAt     *time.Time `json:"submittedAt"`
}

// QuizResultItem is one published quiz's roll-up in the student-detail view
// (read-only — teachers never edit an automatic quiz score, spec §69).
type QuizResultItem struct {
	AssignmentID int64  `json:"assignmentId"`
	Title        string `json:"title"`
	LessonTitle  string `json:"lessonTitle"`
	Attempts     int    `json:"attempts"`
	BestPercent  *int   `json:"bestPercent"`
	Passed       bool   `json:"passed"`
}

// StudentDetail is GET /teacher/groups/:id/students/:studentId.
type StudentDetail struct {
	Student     StudentBrief            `json:"student"`
	Course      CourseBrief             `json:"course"`
	Progress    ProgressBrief           `json:"progress"`
	Lessons     []LessonProgressItem    `json:"lessons"`
	Submissions []SubmissionSummaryItem `json:"submissions"`
	QuizResults []QuizResultItem        `json:"quizResults"`
}

// SubmissionListItem is one row of GET /teacher/submissions.
type SubmissionListItem struct {
	ID          int64           `json:"id"`
	Status      string          `json:"status"`
	SubmittedAt *time.Time      `json:"submittedAt"`
	Student     StudentBrief    `json:"student"`
	Course      CourseBrief     `json:"course"`
	Lesson      LessonBrief     `json:"lesson"`
	Assignment  AssignmentBrief `json:"assignment"`
}

type LessonBrief struct {
	ID    int64  `json:"id"`
	Title string `json:"title"`
}

type AssignmentBrief struct {
	ID     int64  `json:"id"`
	Title  string `json:"title"`
	Points int    `json:"points"`
}

// SubmissionDetail is GET /teacher/submissions/:id.
type SubmissionDetail struct {
	ID              int64      `json:"id"`
	Status          string     `json:"status"`
	Code            *string    `json:"code"`
	Answer          *string    `json:"answer"`
	Score           *int       `json:"score"`
	TeacherFeedback *string    `json:"teacherFeedback"`
	SubmittedAt     *time.Time `json:"submittedAt"`
	CheckedAt       *time.Time `json:"checkedAt"`

	Student StudentBrief `json:"student"`
	Group   struct {
		ID    int64  `json:"id"`
		Title string `json:"title"`
	} `json:"group"`
	Course CourseBrief `json:"course"`
	Module struct {
		ID    int64  `json:"id"`
		Title string `json:"title"`
	} `json:"module"`
	Lesson     LessonBrief `json:"lesson"`
	Assignment struct {
		ID             int64   `json:"id"`
		Title          string  `json:"title"`
		Description    *string `json:"description"`
		AssignmentType string  `json:"assignmentType"`
		StarterCode    *string `json:"starterCode"`
		ExpectedOutput *string `json:"expectedOutput"`
		Language       *string `json:"language"`
		Points         int     `json:"points"`
	} `json:"assignment"`
}

// ReviewRequest is the POST /teacher/submissions/:id/review body.
type ReviewRequest struct {
	Score    *int   `json:"score"`
	Feedback string `json:"feedback"`
	Status   string `json:"status" binding:"required"` // "passed" | "failed"
}

// ListMeta is the pagination envelope for GET /teacher/submissions.
type ListMeta struct {
	Page  int `json:"page"`
	Limit int `json:"limit"`
	Total int `json:"total"`
}

// SubmissionFilter holds the optional query params of GET /teacher/submissions.
type SubmissionFilter struct {
	Status   string
	GroupID  *int64
	CourseID *int64
	Page     int
	Limit    int
}
