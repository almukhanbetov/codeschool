package quizzes

import "time"

/* ================= student: start attempt ================= */

// AttemptBrief is the minimal attempt shape.
type AttemptBrief struct {
	ID          int64      `json:"id"`
	Status      string     `json:"status"`
	StartedAt   time.Time  `json:"startedAt"`
	SubmittedAt *time.Time `json:"submittedAt"`
}

// StudentOption is an option as the student sees it — never `isCorrect`
// (spec §7, §22, §84).
type StudentOption struct {
	ID         int64  `json:"id"`
	OptionText string `json:"optionText"`
	Position   int    `json:"position"`
}

// StudentQuestion is a question as the student sees it — no `isCorrect`, no
// `explanation` before the attempt is submitted.
type StudentQuestion struct {
	ID           int64           `json:"id"`
	QuestionText string          `json:"questionText"`
	QuestionType string          `json:"questionType"`
	Points       int             `json:"points"`
	Position     int             `json:"position"`
	Options      []StudentOption `json:"options"`
}

// StudentQuiz is the quiz payload delivered when an attempt starts / resumes.
type StudentQuiz struct {
	AssignmentID int64             `json:"assignmentId"`
	Title        string            `json:"title"`
	PassPercent  int               `json:"passPercent"`
	Questions    []StudentQuestion `json:"questions"`
}

// StartAttemptResponse is POST /assignments/:id/quiz/attempts.
type StartAttemptResponse struct {
	Attempt AttemptBrief `json:"attempt"`
	Quiz    StudentQuiz  `json:"quiz"`
}

/* ================= student: submit ================= */

// SubmitAnswer is one question's answer in the submit body.
type SubmitAnswer struct {
	QuestionID        int64   `json:"questionId"`
	SelectedOptionIDs []int64 `json:"selectedOptionIds"`
}

// SubmitRequest is POST /quiz/attempts/:id/submit.
type SubmitRequest struct {
	Answers []SubmitAnswer `json:"answers"`
}

/* ================= student: result ================= */

// ResultOption is an option in the post-submit review. `isCorrect` is only
// populated when the quiz settings allow it (spec §39).
type ResultOption struct {
	ID         int64  `json:"id"`
	OptionText string `json:"optionText"`
	Position   int    `json:"position"`
	Selected   bool   `json:"selected"`
	IsCorrect  *bool  `json:"isCorrect"`
}

// ResultQuestion is one question in the post-submit review.
type ResultQuestion struct {
	QuestionID    int64          `json:"questionId"`
	QuestionText  string         `json:"questionText"`
	QuestionType  string         `json:"questionType"`
	Points        int            `json:"points"`
	PointsAwarded int            `json:"pointsAwarded"`
	IsCorrect     bool           `json:"isCorrect"`
	Explanation   *string        `json:"explanation"`
	Options       []ResultOption `json:"options"`
}

// AttemptResult is the graded attempt (POST submit response and GET
// /quiz/attempts/:id for a submitted attempt).
type AttemptResult struct {
	AttemptID          int64            `json:"attemptId"`
	AssignmentID       int64            `json:"assignmentId"`
	Status             string           `json:"status"`
	Score              int              `json:"score"`
	MaxScore           int              `json:"maxScore"`
	Percent            int              `json:"percent"`
	Passed             bool             `json:"passed"`
	PassPercent        int              `json:"passPercent"`
	SubmittedAt        *time.Time       `json:"submittedAt"`
	ShowCorrectAnswers bool             `json:"showCorrectAnswers"`
	Questions          []ResultQuestion `json:"questions"`
}

// AttemptDetail is GET /quiz/attempts/:id: a resumable quiz while the attempt
// is in progress, or the graded result once it is submitted.
type AttemptDetail struct {
	Attempt AttemptBrief   `json:"attempt"`
	Quiz    *StudentQuiz   `json:"quiz"`
	Result  *AttemptResult `json:"result"`
}

/* ================= student: history ================= */

// HistoryItem is one row of the attempt history.
type HistoryItem struct {
	AttemptID     int64      `json:"attemptId"`
	AttemptNumber int        `json:"attemptNumber"`
	Status        string     `json:"status"`
	Score         *int       `json:"score"`
	MaxScore      *int       `json:"maxScore"`
	Percent       *int       `json:"percent"`
	Passed        *bool      `json:"passed"`
	StartedAt     time.Time  `json:"startedAt"`
	SubmittedAt   *time.Time `json:"submittedAt"`
}

// AttemptHistory is GET /assignments/:id/quiz/attempts — the list plus the
// roll-up a dashboard needs (spec §41, §43).
type AttemptHistory struct {
	AssignmentID int64         `json:"assignmentId"`
	Title        string        `json:"title"`
	PassPercent  int           `json:"passPercent"`
	MaxAttempts  *int          `json:"maxAttempts"`
	AttemptsUsed int           `json:"attemptsUsed"`
	AttemptsLeft *int          `json:"attemptsLeft"`
	CanStart     bool          `json:"canStart"`
	Passed       bool          `json:"passed"`
	BestScore    *int          `json:"bestScore"`
	BestMaxScore *int          `json:"bestMaxScore"`
	BestPercent  *int          `json:"bestPercent"`
	InProgressID *int64        `json:"inProgressId"`
	Attempts     []HistoryItem `json:"attempts"`
}

/* ================= admin authoring ================= */

// AdminOption is an option as the admin sees it — full detail incl `isCorrect`.
type AdminOption struct {
	ID         int64  `json:"id"`
	OptionText string `json:"optionText"`
	IsCorrect  bool   `json:"isCorrect"`
	Position   int    `json:"position"`
	IsActive   bool   `json:"isActive"`
}

// AdminQuestion is a question as the admin sees it.
type AdminQuestion struct {
	ID           int64         `json:"id"`
	QuestionText string        `json:"questionText"`
	QuestionType string        `json:"questionType"`
	Points       int           `json:"points"`
	Position     int           `json:"position"`
	Explanation  *string       `json:"explanation"`
	IsActive     bool          `json:"isActive"`
	WellFormed   bool          `json:"wellFormed"`
	Options      []AdminOption `json:"options"`
}

// AdminSettings is the settings shape in the admin quiz view.
type AdminSettings struct {
	PassPercent        int  `json:"passPercent"`
	MaxAttempts        *int `json:"maxAttempts"`
	ShowCorrectAnswers bool `json:"showCorrectAnswers"`
	ShowExplanations   bool `json:"showExplanations"`
}

// AdminQuiz is GET /admin/assignments/:id/quiz.
type AdminQuiz struct {
	AssignmentID   int64           `json:"assignmentId"`
	AssignmentType string          `json:"assignmentType"`
	Title          string          `json:"title"`
	Settings       AdminSettings   `json:"settings"`
	Questions      []AdminQuestion `json:"questions"`
}

// UpdateSettingsRequest is PUT /admin/assignments/:id/quiz/settings — a full
// replacement (spec §61 uses PUT), so `maxAttempts: null` means unlimited.
type UpdateSettingsRequest struct {
	PassPercent        int  `json:"passPercent"`
	MaxAttempts        *int `json:"maxAttempts"`
	ShowCorrectAnswers bool `json:"showCorrectAnswers"`
	ShowExplanations   bool `json:"showExplanations"`
}

// CreateOptionInput is one inline option in CreateQuestionRequest.
type CreateOptionInput struct {
	OptionText string `json:"optionText"`
	IsCorrect  bool   `json:"isCorrect"`
	Position   *int   `json:"position"`
}

// CreateQuestionRequest is POST /admin/assignments/:id/quiz/questions.
type CreateQuestionRequest struct {
	QuestionText string              `json:"questionText"`
	QuestionType string              `json:"questionType"`
	Points       *int                `json:"points"`
	Position     *int                `json:"position"`
	Explanation  *string             `json:"explanation"`
	IsActive     *bool               `json:"isActive"`
	Options      []CreateOptionInput `json:"options"`
}

// UpdateQuestionRequest is PATCH /admin/quiz/questions/:id (sparse).
type UpdateQuestionRequest struct {
	QuestionText *string `json:"questionText"`
	QuestionType *string `json:"questionType"`
	Points       *int    `json:"points"`
	Position     *int    `json:"position"`
	Explanation  *string `json:"explanation"`
	IsActive     *bool   `json:"isActive"`
}

// CreateOptionRequest is POST /admin/quiz/questions/:id/options.
type CreateOptionRequest struct {
	OptionText string `json:"optionText"`
	IsCorrect  *bool  `json:"isCorrect"`
	Position   *int   `json:"position"`
}

// UpdateOptionRequest is PATCH /admin/quiz/options/:id (sparse).
type UpdateOptionRequest struct {
	OptionText *string `json:"optionText"`
	IsCorrect  *bool   `json:"isCorrect"`
	Position   *int    `json:"position"`
	IsActive   *bool   `json:"isActive"`
}

// DeleteResult tells the caller whether a hard delete or a soft-deactivate
// happened (spec §64–§66 — referenced rows are kept for history).
type DeleteResult struct {
	Deleted     bool `json:"deleted"`
	Deactivated bool `json:"deactivated"`
}

/* ================= teacher / parent read views ================= */

// QuizResultBrief is the per-assignment quiz roll-up shown to teachers/parents.
type QuizResultBrief struct {
	AssignmentID int64  `json:"assignmentId"`
	Title        string `json:"title"`
	LessonTitle  string `json:"lessonTitle"`
	Attempts     int    `json:"attempts"`
	BestPercent  *int   `json:"bestPercent"`
	Passed       bool   `json:"passed"`
}
