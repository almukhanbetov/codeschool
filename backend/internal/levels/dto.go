package levels

// Response is the public JSON shape for a level.
type Response struct {
	ID          int64  `json:"id"`
	ProgramID   int64  `json:"programId"`
	Title       string `json:"title"`
	Description string `json:"description,omitempty"`
	AgeFrom     *int   `json:"ageFrom"`
	AgeTo       *int   `json:"ageTo"`
	Position    int    `json:"position"`
}

func toResponse(l Level) Response {
	resp := Response{
		ID:        l.ID,
		ProgramID: l.ProgramID,
		Title:     l.Title,
		AgeFrom:   l.AgeFrom,
		AgeTo:     l.AgeTo,
		Position:  l.Position,
	}
	if l.Description != nil {
		resp.Description = *l.Description
	}
	return resp
}

func toResponseList(items []Level) []Response {
	out := make([]Response, 0, len(items))
	for _, l := range items {
		out = append(out, toResponse(l))
	}
	return out
}
