package progress

import "time"

// LessonProgressResponse is the per-lesson progress shape.
type LessonProgressResponse struct {
	LessonID        int64      `json:"lessonId"`
	Status          string     `json:"status"`
	ProgressPercent int        `json:"progressPercent"`
	StartedAt       *time.Time `json:"startedAt"`
	CompletedAt     *time.Time `json:"completedAt"`
}

func toLessonResponse(p LessonProgress) LessonProgressResponse {
	return LessonProgressResponse{
		LessonID:        p.LessonID,
		Status:          p.Status,
		ProgressPercent: p.ProgressPercent,
		StartedAt:       p.StartedAt,
		CompletedAt:     p.CompletedAt,
	}
}

// CourseProgressResponse is one row of GET /me/progress.
type CourseProgressResponse struct {
	CourseID         int64  `json:"courseId"`
	Title            string `json:"title"`
	CompletedLessons int    `json:"completedLessons"`
	TotalLessons     int    `json:"totalLessons"`
	ProgressPercent  int    `json:"progressPercent"`
}

func toCourseResponse(c CourseCounts) CourseProgressResponse {
	return CourseProgressResponse{
		CourseID:         c.CourseID,
		Title:            c.Title,
		CompletedLessons: c.CompletedLessons,
		TotalLessons:     c.TotalLessons,
		ProgressPercent:  c.Percent(),
	}
}

// CourseDetailResponse is GET /me/courses/:id/progress — the course tally plus
// every published lesson's status, for the learning page's sidebar.
type CourseDetailResponse struct {
	CourseProgressResponse
	EnrollmentStatus string                   `json:"enrollmentStatus"`
	Lessons          []LessonProgressResponse `json:"lessons"`
}

// CompleteLessonResponse is returned by POST /lessons/:id/complete.
type CompleteLessonResponse struct {
	Lesson              LessonProgressResponse `json:"lesson"`
	Course              CourseProgressResponse `json:"course"`
	EnrollmentCompleted bool                   `json:"enrollmentCompleted"`
}
