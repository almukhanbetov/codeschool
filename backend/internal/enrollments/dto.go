package enrollments

import "time"

// Response is the public JSON shape for an enrollment.
type Response struct {
	ID          int64      `json:"id"`
	StudentID   int64      `json:"studentId"`
	CourseID    int64      `json:"courseId"`
	Status      string     `json:"status"`
	EnrolledAt  time.Time  `json:"enrolledAt"`
	CompletedAt *time.Time `json:"completedAt,omitempty"`
}

func toResponse(e Enrollment) Response {
	return Response{
		ID:          e.ID,
		StudentID:   e.StudentID,
		CourseID:    e.CourseID,
		Status:      e.Status,
		EnrolledAt:  e.EnrolledAt,
		CompletedAt: e.CompletedAt,
	}
}

// CourseBrief is the trimmed course shape embedded in a "my courses" item —
// just enough for a card, not the full catalog payload.
type CourseBrief struct {
	ID               int64   `json:"id"`
	Title            string  `json:"title"`
	Slug             string  `json:"slug"`
	ShortDescription *string `json:"shortDescription"`
	ImageURL         *string `json:"imageUrl"`
	DurationLessons  *int    `json:"durationLessons"`
}

// MyCourseItem is one row of GET /me/courses.
type MyCourseItem struct {
	EnrollmentID int64       `json:"enrollmentId"`
	Status       string      `json:"status"`
	EnrolledAt   time.Time   `json:"enrolledAt"`
	Course       CourseBrief `json:"course"`
}
