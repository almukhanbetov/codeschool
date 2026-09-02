package programs

import "time"

// Program is the internal representation of a row in the programs table.
type Program struct {
	ID          int64
	Title       string
	Slug        string
	Description *string
	AgeFrom     *int
	AgeTo       *int
	IsActive    bool
	CreatedAt   time.Time
	UpdatedAt   time.Time
}
