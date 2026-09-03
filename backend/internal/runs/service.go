package runs

import (
	"context"
	"errors"
	"fmt"
	"strings"
	"sync"
	"time"

	"codeschool/backend/internal/assignments"
	"codeschool/backend/internal/submissions"
)

// assignmentResolver resolves a published assignment + its owning course.
// Satisfied by *assignments.Service.
type assignmentResolver interface {
	ResolveForSubmission(ctx context.Context, assignmentID int64) (assignments.Assignment, int64, error)
}

// enrollmentChecker — satisfied by *enrollments.Service.
type enrollmentChecker interface {
	IsEnrolled(ctx context.Context, studentID, courseID int64) (bool, error)
}

// autoGrader applies a machine verdict to the student's code submission.
// Satisfied by *submissions.Service.
type autoGrader interface {
	AutoGradeSubmit(ctx context.Context, studentID, assignmentID int64, code string, score *int, passed bool, summary string) (submissions.Response, error)
}

// codeRunner forwards one program to the sandboxed executor. Satisfied by
// *RunnerClient; a fake stands in for it in tests.
type codeRunner interface {
	Execute(ctx context.Context, language, source, stdin string, wallMS int) (execResult, error)
}

type Service struct {
	repo   *Repository
	client codeRunner
	assign assignmentResolver
	enroll enrollmentChecker
	subs   autoGrader

	mu      sync.Mutex
	lastRun map[int64]time.Time // studentID -> last run time (throttle)
}

func NewService(repo *Repository, client *RunnerClient, assign assignmentResolver, enroll enrollmentChecker, subs autoGrader) *Service {
	s := &Service{
		repo:    repo,
		assign:  assign,
		enroll:  enroll,
		subs:    subs,
		lastRun: map[int64]time.Time{},
	}
	if client != nil { // keep the interface nil when the runner is disabled
		s.client = client
	}
	return s
}

// Enabled reports whether a runner is configured.
func (s *Service) Enabled() bool { return s.client != nil }

// resolve authorizes: the assignment must be a published `code` assignment
// with a language, and the student must be enrolled. Returns the assignment.
func (s *Service) resolve(ctx context.Context, studentID, assignmentID int64) (assignments.Assignment, error) {
	a, courseID, err := s.assign.ResolveForSubmission(ctx, assignmentID)
	if errors.Is(err, assignments.ErrNotFound) {
		return assignments.Assignment{}, ErrAssignmentNotFound
	}
	if err != nil {
		return assignments.Assignment{}, err
	}
	if a.AssignmentType != assignments.TypeCode {
		return assignments.Assignment{}, ErrNotCodeAssignment
	}
	if a.Language == nil || *a.Language == "" || *a.Language == "plaintext" {
		return assignments.Assignment{}, ErrNoLanguage
	}
	enrolled, err := s.enroll.IsEnrolled(ctx, studentID, courseID)
	if err != nil {
		return assignments.Assignment{}, err
	}
	if !enrolled {
		return assignments.Assignment{}, ErrNotEnrolled
	}
	return a, nil
}

func (s *Service) throttle(studentID int64) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	now := time.Now()
	if last, ok := s.lastRun[studentID]; ok && now.Sub(last) < throttlePerRun {
		return ErrThrottled
	}
	s.lastRun[studentID] = now
	return nil
}

func clampCode(code string) (string, error) {
	if strings.TrimSpace(code) == "" {
		return "", invalid("code is empty")
	}
	if len(code) > maxCodeBytes {
		return "", invalid("code is too large")
	}
	return code, nil
}

// Run executes the student's code once (a free "Run", spec §3) and records it.
func (s *Service) Run(ctx context.Context, studentID, assignmentID int64, req RunRequest) (RunResult, error) {
	if !s.Enabled() {
		return RunResult{}, ErrRunnerUnavailable
	}
	a, err := s.resolve(ctx, studentID, assignmentID)
	if err != nil {
		return RunResult{}, err
	}
	code, err := clampCode(req.Code)
	if err != nil {
		return RunResult{}, err
	}
	if err := s.throttle(studentID); err != nil {
		return RunResult{}, err
	}

	stdin := req.Stdin
	if len(stdin) > maxStdinBytes {
		stdin = stdin[:maxStdinBytes]
	}

	res, execErr := s.client.Execute(ctx, *a.Language, code, stdin, defaultWallMS)

	run := Run{
		AssignmentID: assignmentID,
		StudentID:    studentID,
		Language:     *a.Language,
		SourceCode:   code,
		Stdin:        stdin,
		Kind:         KindRun,
	}
	if execErr != nil {
		var ve *ValidationError
		if errors.As(execErr, &ve) {
			run.Status = StatusRunnerError
			run.Stderr = ve.Message
		} else if errors.Is(execErr, ErrRunnerUnavailable) {
			return RunResult{}, ErrRunnerUnavailable
		} else {
			return RunResult{}, execErr
		}
	} else {
		run.Stdout = res.Stdout
		run.Stderr = res.Stderr
		ec := res.ExitCode
		run.ExitCode = &ec
		d := int(res.DurationMS)
		run.DurationMS = &d
		run.Truncated = res.Truncated
		switch {
		case res.TimedOut:
			run.Status = StatusTimeout
		case res.ExitCode == 0:
			run.Status = StatusOK
		default:
			run.Status = StatusError
		}
	}

	saved, err := s.repo.InsertRun(ctx, run)
	if err != nil {
		return RunResult{}, err
	}
	return RunResult{
		RunID:      saved.ID,
		Language:   saved.Language,
		Status:     saved.Status,
		Stdout:     saved.Stdout,
		Stderr:     saved.Stderr,
		ExitCode:   saved.ExitCode,
		TimedOut:   saved.Status == StatusTimeout,
		Truncated:  saved.Truncated,
		DurationMS: saved.DurationMS,
		CreatedAt:  saved.CreatedAt,
	}, nil
}

// History returns the student's recent runs for an assignment (spec §5).
func (s *Service) History(ctx context.Context, studentID, assignmentID int64) ([]RunHistoryItem, error) {
	if _, err := s.resolve(ctx, studentID, assignmentID); err != nil {
		return nil, err
	}
	rows, err := s.repo.ListRuns(ctx, studentID, assignmentID, historyLimit)
	if err != nil {
		return nil, err
	}
	out := make([]RunHistoryItem, 0, len(rows))
	for _, r := range rows {
		out = append(out, RunHistoryItem{
			RunID:      r.ID,
			Kind:       r.Kind,
			Status:     r.Status,
			ExitCode:   r.ExitCode,
			DurationMS: r.DurationMS,
			Stdout:     r.Stdout,
			Stderr:     r.Stderr,
			CreatedAt:  r.CreatedAt,
		})
	}
	return out, nil
}

// VisibleTests returns the non-hidden sample tests (spec §6).
func (s *Service) VisibleTests(ctx context.Context, studentID, assignmentID int64) (TestsResponse, error) {
	if _, err := s.resolve(ctx, studentID, assignmentID); err != nil {
		return TestsResponse{}, err
	}
	all, err := s.repo.TestsForAssignment(ctx, assignmentID)
	if err != nil {
		return TestsResponse{}, err
	}
	resp := TestsResponse{HasTests: len(all) > 0, Total: len(all), Visible: []VisibleTest{}}
	for _, t := range all {
		if t.IsHidden {
			continue
		}
		resp.Visible = append(resp.Visible, VisibleTest{
			ID: t.ID, Name: t.Name, Stdin: t.Stdin, ExpectedStdout: t.ExpectedStdout,
		})
	}
	return resp, nil
}

// Submit runs every test case (visible + hidden), auto-grades and finalizes
// the code submission (spec §7). The assignment must have at least one test.
func (s *Service) Submit(ctx context.Context, studentID, assignmentID int64, req GradeRequest) (GradeResult, error) {
	if !s.Enabled() {
		return GradeResult{}, ErrRunnerUnavailable
	}
	a, err := s.resolve(ctx, studentID, assignmentID)
	if err != nil {
		return GradeResult{}, err
	}
	code, err := clampCode(req.Code)
	if err != nil {
		return GradeResult{}, err
	}
	tests, err := s.repo.TestsForAssignment(ctx, assignmentID)
	if err != nil {
		return GradeResult{}, err
	}
	if len(tests) == 0 {
		return GradeResult{}, ErrNoTests
	}

	execs := make([]testExecution, 0, len(tests))
	for _, tc := range tests {
		res, execErr := s.client.Execute(ctx, *a.Language, code, tc.Stdin, graderWallMS)
		if execErr != nil {
			if errors.Is(execErr, ErrRunnerUnavailable) {
				return GradeResult{}, ErrRunnerUnavailable
			}
			execs = append(execs, testExecution{test: tc, ranErr: true, result: execResult{Stderr: execErr.Error()}})
			continue
		}
		execs = append(execs, testExecution{test: tc, result: res})
	}

	g := gradeAll(execs)
	score := scaleScore(g.percent, a.Points)
	summary := fmt.Sprintf("Автопроверка: %d из %d тестов пройдено (%d%%).", g.passedCount, g.total, g.percent)
	if g.allPassed {
		summary = fmt.Sprintf("Автопроверка: все %d тестов пройдено (100%%).", g.total)
	}

	sub, err := s.subs.AutoGradeSubmit(ctx, studentID, assignmentID, code, score, g.allPassed, summary)
	if err != nil {
		return GradeResult{}, err
	}

	// Persist a compact record of the grading run for history.
	gradeRun := Run{
		AssignmentID: assignmentID, StudentID: studentID, Language: *a.Language,
		SourceCode: code, Kind: KindGrade, Status: StatusOK,
		Stdout: summary,
	}
	if !g.allPassed {
		gradeRun.Status = StatusError
	}
	_, _ = s.repo.InsertRun(ctx, gradeRun)

	out := GradeResult{
		SubmissionID: sub.ID,
		Status:       sub.Status,
		Passed:       g.allPassed,
		Score:        score,
		Points:       a.Points,
		Percent:      g.percent,
		TestsPassed:  g.passedCount,
		TestsTotal:   g.total,
		Feedback:     summary,
		Outcomes:     make([]TestOutcome, 0, len(g.verdicts)),
	}
	for _, v := range g.verdicts {
		oc := TestOutcome{
			TestID: v.test.ID, Name: v.test.Name, Hidden: v.test.IsHidden,
			Passed: v.passed, Timedout: v.timedOut,
		}
		if !v.passed && !v.test.IsHidden {
			oc.Stdin = v.test.Stdin
			oc.Expected = v.test.ExpectedStdout
			oc.Got = v.got
			oc.Stderr = v.stderr
		}
		out.Outcomes = append(out.Outcomes, oc)
	}
	return out, nil
}

/* ---- progress gate helper ---- */

// AssignmentIDsWithTests — which of the ids are test-graded code assignments.
func (s *Service) AssignmentIDsWithTests(ctx context.Context, assignmentIDs []int64) ([]int64, error) {
	return s.repo.AssignmentIDsWithTests(ctx, assignmentIDs)
}
