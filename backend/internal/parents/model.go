// Package parents implements the parent flow: a read-only view of a parent's
// linked children — their courses, progress, assignments, and the teacher's
// feedback. Every endpoint is a GET; nothing here mutates state.
package parents

// Activity item types returned by the activity summary.
const (
	ActivityLessonCompleted     = "lesson_completed"
	ActivityAssignmentSubmitted = "assignment_submitted"
	ActivityAssignmentPassed    = "assignment_passed"
	ActivityAssignmentFailed    = "assignment_failed"
)

// activityLimit bounds the activity timeline (no pagination this stage).
const activityLimit = 25
