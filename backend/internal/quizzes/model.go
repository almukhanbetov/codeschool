// Package quizzes implements the quiz engine: admin authoring (settings,
// questions, options), student attempts, automatic scoring, and the read-only
// teacher / parent views. Quizzes never create a submissions row — quiz state
// lives entirely in quiz_attempts / quiz_attempt_answers (spec §46).
package quizzes

import "time"

// question_type values — see migration 00017's CHECK constraint.
const (
	QuestionSingleChoice   = "single_choice"
	QuestionMultipleChoice = "multiple_choice"
	QuestionTrueFalse      = "true_false"
)

// quiz_attempts.status values — see migration 00019's CHECK constraint.
const (
	AttemptInProgress = "in_progress"
	AttemptSubmitted  = "submitted"
)

// Settings defaults (used when an assignment has no quiz_settings row yet).
const (
	defaultPassPercent = 70
)

var questionTypes = map[string]bool{
	QuestionSingleChoice:   true,
	QuestionMultipleChoice: true,
	QuestionTrueFalse:      true,
}

// Question is the internal representation of a quiz_questions row plus its
// options (loaded together to avoid N+1).
type Question struct {
	ID           int64
	AssignmentID int64
	Text         string
	Type         string
	Points       int
	Position     int
	Explanation  *string
	IsActive     bool
	Options      []Option
}

// Option is a quiz_options row.
type Option struct {
	ID         int64
	QuestionID int64
	Text       string
	IsCorrect  bool
	Position   int
	IsActive   bool
}

// correctOptionIDs returns the ids of the question's active correct options.
func (q Question) correctOptionIDs() []int64 {
	var out []int64
	for _, o := range q.Options {
		if o.IsActive && o.IsCorrect {
			out = append(out, o.ID)
		}
	}
	return out
}

// activeOptionIDs returns the ids of the question's active options.
func (q Question) activeOptionIDs() map[int64]bool {
	out := map[int64]bool{}
	for _, o := range q.Options {
		if o.IsActive {
			out[o.ID] = true
		}
	}
	return out
}

// wellFormed reports whether the question satisfies its type's answer-key rule
// (spec §9, §10, §60). Only active options count.
func (q Question) wellFormed() bool {
	correct, active := 0, 0
	for _, o := range q.Options {
		if !o.IsActive {
			continue
		}
		active++
		if o.IsCorrect {
			correct++
		}
	}
	switch q.Type {
	case QuestionSingleChoice:
		return active >= 2 && correct == 1
	case QuestionTrueFalse:
		return active == 2 && correct == 1
	case QuestionMultipleChoice:
		return active >= 2 && correct >= 1
	default:
		return false
	}
}

// Settings is a quiz_settings row (or the defaults).
type Settings struct {
	AssignmentID       int64
	PassPercent        int
	MaxAttempts        *int
	ShowCorrectAnswers bool
	ShowExplanations   bool
}

func defaultSettings(assignmentID int64) Settings {
	return Settings{
		AssignmentID:       assignmentID,
		PassPercent:        defaultPassPercent,
		MaxAttempts:        nil,
		ShowCorrectAnswers: true,
		ShowExplanations:   true,
	}
}

// Attempt is a quiz_attempts row.
type Attempt struct {
	ID           int64
	AssignmentID int64
	StudentID    int64
	Status       string
	Score        *int
	MaxScore     *int
	Percent      *int
	Passed       *bool
	StartedAt    time.Time
	SubmittedAt  *time.Time
}

// assignmentMeta is the joined assignment context a quiz operation needs.
type assignmentMeta struct {
	AssignmentID    int64
	Title           string
	AssignmentType  string
	CourseID        int64
	IsPublished     bool
	LessonPublished bool
}

func (m assignmentMeta) studentVisible() bool {
	return m.IsPublished && m.LessonPublished
}
