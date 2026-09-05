package support

import "context"

// RefTitles returns the display titles for the (optional) course / lesson /
// assignment a thread is attached to — used to compose the opening system
// message and the thread's "about" line.
func (r *Repository) RefTitles(ctx context.Context, courseID, lessonID, assignmentID *int64) (course, lesson, assignment *string, err error) {
	if courseID != nil {
		var s string
		if e := r.pool.QueryRow(ctx, `SELECT title FROM courses WHERE id = $1`, *courseID).Scan(&s); e == nil {
			course = &s
		}
	}
	if lessonID != nil {
		var s string
		if e := r.pool.QueryRow(ctx, `SELECT title FROM lessons WHERE id = $1`, *lessonID).Scan(&s); e == nil {
			lesson = &s
		}
	}
	if assignmentID != nil {
		var s string
		if e := r.pool.QueryRow(ctx, `SELECT title FROM assignments WHERE id = $1`, *assignmentID).Scan(&s); e == nil {
			assignment = &s
		}
	}
	return course, lesson, assignment, nil
}
