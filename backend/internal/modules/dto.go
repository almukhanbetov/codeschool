package modules

// Response is the public JSON shape for a module.
type Response struct {
	ID          int64  `json:"id"`
	CourseID    int64  `json:"courseId"`
	Title       string `json:"title"`
	Description string `json:"description,omitempty"`
	Position    int    `json:"position"`
}

// ToResponse converts a Module model to its public JSON shape. Exported so
// the courses package can build the /courses/:id/content aggregate.
func ToResponse(m Module) Response {
	resp := Response{
		ID:       m.ID,
		CourseID: m.CourseID,
		Title:    m.Title,
		Position: m.Position,
	}
	if m.Description != nil {
		resp.Description = *m.Description
	}
	return resp
}

func toResponseList(items []Module) []Response {
	out := make([]Response, 0, len(items))
	for _, m := range items {
		out = append(out, ToResponse(m))
	}
	return out
}
