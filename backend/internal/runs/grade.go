package runs

import "strings"

// Pure grading — no DB, no HTTP — so the comparison + weighting rules are
// unit-tested in isolation (spec §7).

// normalizeOutput trims trailing whitespace on every line and drops trailing
// blank lines. This is the usual "close enough" comparison for classroom I/O
// (a stray trailing newline or trailing spaces should not fail a test).
func normalizeOutput(s string) string {
	s = strings.ReplaceAll(s, "\r\n", "\n")
	lines := strings.Split(s, "\n")
	for i := range lines {
		lines[i] = strings.TrimRight(lines[i], " \t")
	}
	for len(lines) > 0 && lines[len(lines)-1] == "" {
		lines = lines[:len(lines)-1]
	}
	return strings.Join(lines, "\n")
}

func outputsMatch(got, expected string) bool {
	return normalizeOutput(got) == normalizeOutput(expected)
}

// testExecution pairs a test case with the sandbox result of running the
// student's code against it.
type testExecution struct {
	test   TestCase
	result execResult
	// ranErr is true when the runner itself failed for this test.
	ranErr bool
}

// verdict is the graded outcome of one test.
type verdict struct {
	test     TestCase
	passed   bool
	timedOut bool
	got      string
	stderr   string
}

// gradeOutcome is the whole-submission grade.
type gradeOutcome struct {
	total       int
	passedCount int
	weighted    int
	maxWeight   int
	percent     int
	allPassed   bool
	verdicts    []verdict
}

func gradeAll(execs []testExecution) gradeOutcome {
	out := gradeOutcome{total: len(execs), allPassed: len(execs) > 0}
	for _, e := range execs {
		out.maxWeight += e.test.Weight
		v := verdict{test: e.test, stderr: e.result.Stderr, got: e.result.Stdout, timedOut: e.result.TimedOut}
		if !e.ranErr && !e.result.TimedOut && e.result.ExitCode == 0 && outputsMatch(e.result.Stdout, e.test.ExpectedStdout) {
			v.passed = true
			out.passedCount++
			out.weighted += e.test.Weight
		} else {
			out.allPassed = false
		}
		out.verdicts = append(out.verdicts, v)
	}
	out.percent = percentOf(out.weighted, out.maxWeight)
	return out
}

func percentOf(n, d int) int {
	if d <= 0 {
		return 0
	}
	return n * 100 / d
}

// scaleScore converts a percent to the assignment's points scale (nil when the
// assignment carries no points).
func scaleScore(percent, points int) *int {
	if points <= 0 {
		return nil
	}
	v := (percent*points + 50) / 100 // round to nearest
	if v > points {
		v = points
	}
	return &v
}
