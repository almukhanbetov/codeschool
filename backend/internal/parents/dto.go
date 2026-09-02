package parents

import "time"

// ChildBrief is the trimmed, safe child shape — never a password hash,
// tokens, phone, or email.
type ChildBrief struct {
	ID        int64   `json:"id"`
	FirstName string  `json:"firstName"`
	LastName  *string `json:"lastName"`
}

// CourseBrief is the trimmed course shape embedded in parent responses.
type CourseBrief struct {
	ID    int64  `json:"id"`
	Title string `json:"title"`
	Slug  string `json:"slug"`
}

// ProgressBrief is the completed/total published-lesson tally.
type ProgressBrief struct {
	CompletedLessons int `json:"completedLessons"`
	TotalLessons     int `json:"totalLessons"`
	ProgressPercent  int `json:"progressPercent"`
}

// ChildListItem is one row of GET /parent/children.
type ChildListItem struct {
	Child                  ChildBrief `json:"child"`
	CoursesCount           int        `json:"coursesCount"`
	OverallProgressPercent int        `json:"overallProgressPercent"`
	PendingReview          int        `json:"pendingReview"` // submitted / checking
	NeedsWork              int        `json:"needsWork"`     // failed
}

// ChildCourseProgress is one course + the child's progress in it.
type ChildCourseProgress struct {
	Course           CourseBrief   `json:"course"`
	EnrollmentStatus string        `json:"enrollmentStatus"`
	Progress         ProgressBrief `json:"progress"`
}

// ChildOverview is GET /parent/children/:id.
type ChildOverview struct {
	Child   ChildBrief            `json:"child"`
	Courses []ChildCourseProgress `json:"courses"`
}

// LessonProgressItem is one lesson's status in the course-detail view.
type LessonProgressItem struct {
	LessonID    int64      `json:"lessonId"`
	Title       string     `json:"title"`
	Status      string     `json:"status"`
	CompletedAt *time.Time `json:"completedAt"`
}

// AssignmentFeedbackItem is one assignment + the child's submission state and
// the teacher's feedback (score / feedback / passed-failed).
type AssignmentFeedbackItem struct {
	AssignmentID    int64      `json:"assignmentId"`
	Title           string     `json:"title"`
	LessonTitle     string     `json:"lessonTitle"`
	AssignmentType  string     `json:"assignmentType"`
	Points          int        `json:"points"`
	Status          string     `json:"status"` // "" when there is no submission
	Score           *int       `json:"score"`
	TeacherFeedback *string    `json:"teacherFeedback"`
	SubmittedAt     *time.Time `json:"submittedAt"`
	CheckedAt       *time.Time `json:"checkedAt"`
}

// ChildCourseDetail is GET /parent/children/:id/courses/:courseId.
type ChildCourseDetail struct {
	Child       ChildBrief               `json:"child"`
	Course      CourseBrief              `json:"course"`
	Progress    ProgressBrief            `json:"progress"`
	Lessons     []LessonProgressItem     `json:"lessons"`
	Assignments []AssignmentFeedbackItem `json:"assignments"`
}

// ActivityItem is one event in the child's recent activity timeline.
type ActivityItem struct {
	Type            string    `json:"type"`
	At              time.Time `json:"at"`
	CourseTitle     string    `json:"courseTitle"`
	LessonTitle     string    `json:"lessonTitle"`
	AssignmentTitle *string   `json:"assignmentTitle"`
	Score           *int      `json:"score"`
	Points          *int      `json:"points"`
}

// ActivitySummary is GET /parent/children/:id/activity.
type ActivitySummary struct {
	Child ChildBrief     `json:"child"`
	Items []ActivityItem `json:"items"`
}
