package runs

import "time"

/* ================= student: run ================= */

// RunRequest is POST /assignments/:id/run.
type RunRequest struct {
	Code  string `json:"code"`
	Stdin string `json:"stdin"`
}

// RunResult is one execution's outcome, as returned to the student.
type RunResult struct {
	RunID      int64     `json:"runId"`
	Language   string    `json:"language"`
	Status     string    `json:"status"`
	Stdout     string    `json:"stdout"`
	Stderr     string    `json:"stderr"`
	ExitCode   *int      `json:"exitCode"`
	TimedOut   bool      `json:"timedOut"`
	Truncated  bool      `json:"truncated"`
	DurationMS *int      `json:"durationMs"`
	CreatedAt  time.Time `json:"createdAt"`
}

// RunHistoryItem is one row of GET /assignments/:id/runs.
type RunHistoryItem struct {
	RunID      int64     `json:"runId"`
	Kind       string    `json:"kind"`
	Status     string    `json:"status"`
	ExitCode   *int      `json:"exitCode"`
	DurationMS *int      `json:"durationMs"`
	Stdout     string    `json:"stdout"`
	Stderr     string    `json:"stderr"`
	CreatedAt  time.Time `json:"createdAt"`
}

/* ================= student: tests + grading ================= */

// VisibleTest is a non-hidden sample test case (spec §6).
type VisibleTest struct {
	ID             int64  `json:"id"`
	Name           string `json:"name"`
	Stdin          string `json:"stdin"`
	ExpectedStdout string `json:"expectedStdout"`
}

// TestsResponse is GET /assignments/:id/tests.
type TestsResponse struct {
	HasTests bool          `json:"hasTests"` // includes hidden ones
	Total    int           `json:"total"`
	Visible  []VisibleTest `json:"visible"`
}

// GradeRequest is POST /assignments/:id/code/submit.
type GradeRequest struct {
	Code string `json:"code"`
}

// TestOutcome is one test's verdict. Hidden tests report only pass/fail.
type TestOutcome struct {
	TestID   int64  `json:"testId"`
	Name     string `json:"name"`
	Hidden   bool   `json:"hidden"`
	Passed   bool   `json:"passed"`
	Timedout bool   `json:"timedOut"`
	// Populated only for a FAILED VISIBLE test:
	Stdin    string `json:"stdin,omitempty"`
	Expected string `json:"expected,omitempty"`
	Got      string `json:"got,omitempty"`
	Stderr   string `json:"stderr,omitempty"`
}

// GradeResult is POST /assignments/:id/code/submit.
type GradeResult struct {
	SubmissionID int64         `json:"submissionId"`
	Status       string        `json:"status"` // "passed" | "failed"
	Passed       bool          `json:"passed"`
	Score        *int          `json:"score"`
	Points       int           `json:"points"`
	Percent      int           `json:"percent"`
	TestsPassed  int           `json:"testsPassed"`
	TestsTotal   int           `json:"testsTotal"`
	Feedback     string        `json:"feedback"`
	Outcomes     []TestOutcome `json:"outcomes"`
}

/* ================= admin authoring ================= */

// AdminTest is a full test row for the admin editor.
type AdminTest struct {
	ID             int64     `json:"id"`
	AssignmentID   int64     `json:"assignmentId"`
	Name           string    `json:"name"`
	Stdin          string    `json:"stdin"`
	ExpectedStdout string    `json:"expectedStdout"`
	IsHidden       bool      `json:"isHidden"`
	Weight         int       `json:"weight"`
	Position       int       `json:"position"`
	CreatedAt      time.Time `json:"createdAt"`
	UpdatedAt      time.Time `json:"updatedAt"`
}

type CreateTestRequest struct {
	Name           string `json:"name"`
	Stdin          string `json:"stdin"`
	ExpectedStdout string `json:"expectedStdout"`
	IsHidden       *bool  `json:"isHidden"`
	Weight         *int   `json:"weight"`
	Position       *int   `json:"position"`
}

type UpdateTestRequest struct {
	Name           *string `json:"name"`
	Stdin          *string `json:"stdin"`
	ExpectedStdout *string `json:"expectedStdout"`
	IsHidden       *bool   `json:"isHidden"`
	Weight         *int    `json:"weight"`
	Position       *int    `json:"position"`
}
