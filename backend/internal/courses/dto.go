package courses

import (
	"codeschool/backend/internal/lessons"
	"codeschool/backend/internal/modules"
)

// Response is the public JSON shape for a course, matching the frontend's
// Course type (frontend/types/index.ts).
type Response struct {
	ID               int64   `json:"id"`
	LevelID          int64   `json:"levelId"`
	Title            string  `json:"title"`
	Slug             string  `json:"slug"`
	Description      *string `json:"description"`
	ShortDescription *string `json:"shortDescription"`
	ImageURL         *string `json:"imageUrl"`
	AgeFrom          *int    `json:"ageFrom"`
	AgeTo            *int    `json:"ageTo"`
	DurationLessons  *int    `json:"durationLessons"`
	ProjectsCount    *int    `json:"projectsCount"`
	Difficulty       *string `json:"difficulty"`
}

func toResponse(c Course) Response {
	return Response{
		ID:               c.ID,
		LevelID:          c.LevelID,
		Title:            c.Title,
		Slug:             c.Slug,
		Description:      c.Description,
		ShortDescription: c.ShortDescription,
		ImageURL:         c.ImageURL,
		AgeFrom:          c.AgeFrom,
		AgeTo:            c.AgeTo,
		DurationLessons:  c.DurationLessons,
		ProjectsCount:    c.ProjectsCount,
		Difficulty:       c.Difficulty,
	}
}

func toResponseList(items []Course) []Response {
	out := make([]Response, 0, len(items))
	for _, c := range items {
		out = append(out, toResponse(c))
	}
	return out
}

// ModuleWithLessons is a module response with its lessons nested inline —
// used only by the GET /courses/:id/content aggregate endpoint.
type ModuleWithLessons struct {
	modules.Response
	Lessons []lessons.Response `json:"lessons"`
}

// ContentResponse is the shape returned by GET /courses/:id/content: the
// course plus its modules, each with its own lessons nested inline. It
// exists purely to save the frontend a waterfall of requests when it needs
// the whole course tree at once — the individual /courses/:id,
// /courses/:id/modules and /modules/:id/lessons endpoints remain the normal
// REST resources.
type ContentResponse struct {
	Course  Response            `json:"course"`
	Modules []ModuleWithLessons `json:"modules"`
}
