package assignments

// Response is the JSON shape returned to an enrolled student. It deliberately
// omits nothing sensitive — assignments have no secrets in this stage (no
// quiz answer keys yet).
type Response struct {
	ID             int64   `json:"id"`
	LessonID       int64   `json:"lessonId"`
	Title          string  `json:"title"`
	Description    *string `json:"description"`
	AssignmentType string  `json:"assignmentType"`
	StarterCode    *string `json:"starterCode"`
	ExpectedOutput *string `json:"expectedOutput"`
	Points         int     `json:"points"`
	Position       int     `json:"position"`
}

func toResponse(a Assignment) Response {
	return Response{
		ID:             a.ID,
		LessonID:       a.LessonID,
		Title:          a.Title,
		Description:    a.Description,
		AssignmentType: a.AssignmentType,
		StarterCode:    a.StarterCode,
		ExpectedOutput: a.ExpectedOutput,
		Points:         a.Points,
		Position:       a.Position,
	}
}

func toResponseList(items []Assignment) []Response {
	out := make([]Response, 0, len(items))
	for _, a := range items {
		out = append(out, toResponse(a))
	}
	return out
}
