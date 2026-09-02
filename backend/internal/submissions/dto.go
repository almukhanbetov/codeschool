package submissions

import "time"

// UpsertRequest is the PUT /assignments/:id/submission body.
type UpsertRequest struct {
	Code   *string `json:"code"`
	Answer *string `json:"answer"`
}

// Response is the JSON shape for a student's own submission.
type Response struct {
	ID              int64      `json:"id"`
	AssignmentID    int64      `json:"assignmentId"`
	StudentID       int64      `json:"studentId"`
	Code            *string    `json:"code"`
	Answer          *string    `json:"answer"`
	Status          string     `json:"status"`
	Score           *int       `json:"score"`
	TeacherFeedback *string    `json:"teacherFeedback"`
	SubmittedAt     *time.Time `json:"submittedAt"`
	CheckedAt       *time.Time `json:"checkedAt"`
	UpdatedAt       time.Time  `json:"updatedAt"`
}

func toResponse(s Submission) Response {
	return Response{
		ID:              s.ID,
		AssignmentID:    s.AssignmentID,
		StudentID:       s.StudentID,
		Code:            s.Code,
		Answer:          s.Answer,
		Status:          s.Status,
		Score:           s.Score,
		TeacherFeedback: s.TeacherFeedback,
		SubmittedAt:     s.SubmittedAt,
		CheckedAt:       s.CheckedAt,
		UpdatedAt:       s.UpdatedAt,
	}
}
