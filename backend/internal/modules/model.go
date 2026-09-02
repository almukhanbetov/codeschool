package modules

import "time"

// Module is the internal representation of a row in the modules table.
type Module struct {
	ID          int64
	CourseID    int64
	Title       string
	Description *string
	Position    int
	CreatedAt   time.Time
	UpdatedAt   time.Time
}
