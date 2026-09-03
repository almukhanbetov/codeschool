// Package runs is the backend side of the code runner: it authorizes a
// student, forwards the code to the sandboxed `runner` service, persists the
// execution (attempt history), serves visible test cases, and runs the hidden
// test cases to auto-grade a submission. It never executes code in-process.
package runs

import "time"

// code_runs.status values (see migration 00023).
const (
	StatusOK          = "ok"           // program ran (any exit code)
	StatusError       = "error"        // program ran and exited non-zero
	StatusTimeout     = "timeout"      // wall-clock timeout
	StatusRunnerError = "runner_error" // the runner itself failed / was unreachable
)

// code_runs.kind values.
const (
	KindRun   = "run"
	KindGrade = "grade"
)

const (
	maxCodeBytes   = 200 << 10
	maxStdinBytes  = 16 << 10
	historyLimit   = 20
	throttlePerRun = 1500 * time.Millisecond
	defaultWallMS  = 5000
	graderWallMS   = 5000
)

// Run is a persisted code_runs row.
type Run struct {
	ID           int64
	AssignmentID int64
	StudentID    int64
	Language     string
	SourceCode   string
	Stdin        string
	Stdout       string
	Stderr       string
	ExitCode     *int
	Status       string
	DurationMS   *int
	Truncated    bool
	Kind         string
	CreatedAt    time.Time
}

// TestCase is an assignment_tests row.
type TestCase struct {
	ID             int64
	AssignmentID   int64
	Name           string
	Stdin          string
	ExpectedStdout string
	IsHidden       bool
	Weight         int
	Position       int
}
