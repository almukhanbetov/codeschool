package levels

import "time"

// Level is the internal representation of a row in the levels table.
type Level struct {
	ID          int64
	ProgramID   int64
	Title       string
	Description *string
	AgeFrom     *int
	AgeTo       *int
	Position    int
	CreatedAt   time.Time
	UpdatedAt   time.Time
}
