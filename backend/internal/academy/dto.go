package academy

import "time"

/* ================= teacher-facing ================= */

// CourseCard is one row of GET /teacher-academy/courses.
type CourseCard struct {
	ID               int64   `json:"id"`
	Title            string  `json:"title"`
	Slug             string  `json:"slug"`
	ShortDescription *string `json:"shortDescription"`
	Description      *string `json:"description"`
	ImageURL         *string `json:"imageUrl"`
	Difficulty       *string `json:"difficulty"`
	Audience         string  `json:"audience"`
	TotalLessons     int     `json:"totalLessons"`
	Enrolled         bool    `json:"enrolled"`
}

// MyCourse is one row of GET /teacher-academy/me/courses and the dashboard.
type MyCourse struct {
	CourseID            int64      `json:"courseId"`
	Title               string     `json:"title"`
	Slug                string     `json:"slug"`
	ShortDescription    *string    `json:"shortDescription"`
	ImageURL            *string    `json:"imageUrl"`
	Difficulty          *string    `json:"difficulty"`
	EnrollmentStatus    string     `json:"enrollmentStatus"` // active | completed
	EnrolledAt          time.Time  `json:"enrolledAt"`
	CompletedAt         *time.Time `json:"completedAt"`
	CompletedLessons    int        `json:"completedLessons"`
	TotalLessons        int        `json:"totalLessons"`
	ProgressPercent     int        `json:"progressPercent"`
	CourseCompleted     bool       `json:"courseCompleted"`
	CertificateEligible bool       `json:"certificateEligible"`
}

// Dashboard is GET /teacher-academy/dashboard.
type Dashboard struct {
	CoursesInProgress int        `json:"coursesInProgress"`
	CoursesCompleted  int        `json:"coursesCompleted"`
	TotalCourses      int        `json:"totalCourses"`
	OverallPercent    int        `json:"overallPercent"`
	Courses           []MyCourse `json:"courses"`
}

/* ================= admin-facing ================= */

// LearnerRow is one row of GET /admin/academy/learners.
type LearnerRow struct {
	TeacherID        int64   `json:"teacherId"`
	Name             string  `json:"name"`
	Email            *string `json:"email"`
	CoursesEnrolled  int     `json:"coursesEnrolled"`
	CoursesCompleted int     `json:"coursesCompleted"`
}

// AcademySubmissionRow is one row of GET /admin/academy/submissions.
type AcademySubmissionRow struct {
	ID             int64      `json:"id"`
	Status         string     `json:"status"`
	Score          *int       `json:"score"`
	SubmittedAt    *time.Time `json:"submittedAt"`
	CheckedAt      *time.Time `json:"checkedAt"`
	TeacherID      int64      `json:"teacherId"`
	TeacherName    string     `json:"teacherName"`
	AssignmentID   int64      `json:"assignmentId"`
	AssignmentType string     `json:"assignmentType"`
	AssignmentName string     `json:"assignmentName"`
	Points         int        `json:"points"`
	LessonTitle    string     `json:"lessonTitle"`
	CourseID       int64      `json:"courseId"`
	CourseTitle    string     `json:"courseTitle"`
}

// AcademySubmissionDetail is GET /admin/academy/submissions/:id.
type AcademySubmissionDetail struct {
	AcademySubmissionRow
	Answer                *string `json:"answer"`
	Code                  *string `json:"code"`
	TeacherFeedback       *string `json:"teacherFeedback"`
	AssignmentDescription *string `json:"assignmentDescription"`
	AssignmentLanguage    *string `json:"assignmentLanguage"`
}

// ReviewRequest is POST /admin/academy/submissions/:id/review.
type ReviewRequest struct {
	Score    *int   `json:"score"`
	Feedback string `json:"feedback"`
	Status   string `json:"status"` // passed | failed
}
