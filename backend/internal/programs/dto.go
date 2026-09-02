package programs

// Response is the public JSON shape for a program, matching the frontend's
// camelCase naming convention (see frontend/types/index.ts).
type Response struct {
	ID          int64  `json:"id"`
	Title       string `json:"title"`
	Slug        string `json:"slug"`
	Description string `json:"description,omitempty"`
	AgeFrom     *int   `json:"ageFrom"`
	AgeTo       *int   `json:"ageTo"`
	IsActive    bool   `json:"isActive"`
}

func toResponse(p Program) Response {
	resp := Response{
		ID:       p.ID,
		Title:    p.Title,
		Slug:     p.Slug,
		AgeFrom:  p.AgeFrom,
		AgeTo:    p.AgeTo,
		IsActive: p.IsActive,
	}
	if p.Description != nil {
		resp.Description = *p.Description
	}
	return resp
}

func toResponseList(items []Program) []Response {
	out := make([]Response, 0, len(items))
	for _, p := range items {
		out = append(out, toResponse(p))
	}
	return out
}
