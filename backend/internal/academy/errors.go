// Package academy is the Teacher Academy — a teacher's own professional
// learning. It deliberately adds NO new course engine: modules, lessons,
// assignments, the quiz engine, the code runner, lesson progress and
// submissions are all reused as-is. The only new metadata is
// courses.audience (migration 00025); the only new routes are the
// audience-aware catalog / enrolment / dashboard endpoints below, plus the
// admin review of methodology/project submissions. All the actual learning
// (start/complete a lesson, take a quiz, run code, submit an assignment) goes
// through the existing student-flow handlers, re-registered under the
// /teacher-academy prefix with RequireRole("teacher").
package academy

import "errors"

var (
	ErrCourseNotFound     = errors.New("academy course not found")
	ErrNotTeacherCourse   = errors.New("this course is not a teacher academy course")
	ErrAlreadyEnrolled    = errors.New("already enrolled in this academy course")
	ErrSubmissionNotFound = errors.New("academy submission not found")
)
