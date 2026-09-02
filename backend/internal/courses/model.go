package courses

import "time"

// Course is the internal representation of a row in the courses table.
type Course struct {
	ID               int64
	LevelID          int64
	Title            string
	Slug             string
	Description      *string
	ShortDescription *string
	ImageURL         *string
	AgeFrom          *int
	AgeTo            *int
	DurationLessons  *int
	ProjectsCount    *int
	Difficulty       *string
	IsPublished      bool
	Position         int
	CreatedAt        time.Time
	UpdatedAt        time.Time
}

// ListFilter holds the optional query parameters accepted by GET /courses.
type ListFilter struct {
	AgeFrom *int
	AgeTo   *int
	LevelID *int64
}
