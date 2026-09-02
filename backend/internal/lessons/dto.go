package lessons

// Response is the public JSON shape for a lesson.
type Response struct {
	ID          int64   `json:"id"`
	ModuleID    int64   `json:"moduleId"`
	Title       string  `json:"title"`
	Slug        *string `json:"slug"`
	Description *string `json:"description"`
	Content     *string `json:"content"`
	VideoURL    *string `json:"videoUrl"`
	LessonType  string  `json:"lessonType"`
	Position    int     `json:"position"`
}

// ToResponse converts a Lesson model to its public JSON shape. Exported so
// the courses package can build the /courses/:id/content aggregate.
func ToResponse(l Lesson) Response {
	return Response{
		ID:          l.ID,
		ModuleID:    l.ModuleID,
		Title:       l.Title,
		Slug:        l.Slug,
		Description: l.Description,
		Content:     l.Content,
		VideoURL:    l.VideoURL,
		LessonType:  l.LessonType,
		Position:    l.Position,
	}
}

func toResponseList(items []Lesson) []Response {
	out := make([]Response, 0, len(items))
	for _, l := range items {
		out = append(out, ToResponse(l))
	}
	return out
}
