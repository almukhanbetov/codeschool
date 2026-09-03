package runs

import "testing"

func tc(id int64, expected string, hidden bool, weight int) TestCase {
	return TestCase{ID: id, Name: "t", ExpectedStdout: expected, IsHidden: hidden, Weight: weight}
}
func ok(stdout string) execResult  { return execResult{Stdout: stdout, ExitCode: 0} }
func bad(stderr string) execResult { return execResult{Stderr: stderr, ExitCode: 1} }

func TestNormalizeOutput(t *testing.T) {
	cases := [][2]string{
		{"a\nb\n", "a\nb"},
		{"a  \nb\t\n\n\n", "a\nb"},
		{"a\r\nb\r\n", "a\nb"},
		{"", ""},
	}
	for _, c := range cases {
		if got := normalizeOutput(c[0]); got != c[1] {
			t.Errorf("normalizeOutput(%q) = %q, want %q", c[0], got, c[1])
		}
	}
}

func TestOutputsMatch(t *testing.T) {
	if !outputsMatch("42\n", "42") {
		t.Fatal("trailing newline should still match")
	}
	if outputsMatch("42", "43") {
		t.Fatal("different values must not match")
	}
}

func TestGradeAll(t *testing.T) {
	execs := []testExecution{
		{test: tc(1, "1", false, 1), result: ok("1\n")},   // pass
		{test: tc(2, "2", true, 3), result: ok("2")},      // pass (weight 3)
		{test: tc(3, "3", true, 1), result: ok("nope")},   // fail
		{test: tc(4, "4", false, 1), result: bad("boom")}, // fail (nonzero exit)
		{test: tc(5, "5", true, 1), ranErr: true},         // fail (runner error)
	}
	g := gradeAll(execs)
	if g.total != 5 || g.passedCount != 2 {
		t.Fatalf("passed=%d total=%d", g.passedCount, g.total)
	}
	if g.weighted != 4 || g.maxWeight != 7 {
		t.Fatalf("weighted=%d maxWeight=%d", g.weighted, g.maxWeight)
	}
	if g.percent != 57 { // 4*100/7
		t.Fatalf("percent=%d", g.percent)
	}
	if g.allPassed {
		t.Fatal("not all passed")
	}
}

func TestGradeAll_AllPass(t *testing.T) {
	execs := []testExecution{
		{test: tc(1, "a", false, 1), result: ok("a")},
		{test: tc(2, "b", true, 2), result: ok("b\n")},
	}
	g := gradeAll(execs)
	if !g.allPassed || g.percent != 100 {
		t.Fatalf("%+v", g)
	}
}

func TestGradeAll_TimeoutFails(t *testing.T) {
	execs := []testExecution{{test: tc(1, "x", false, 1), result: execResult{Stdout: "x", TimedOut: true}}}
	if g := gradeAll(execs); g.allPassed {
		t.Fatal("a timed-out test must fail even if stdout matches so far")
	}
}

func TestScaleScore(t *testing.T) {
	if scaleScore(80, 0) != nil {
		t.Fatal("points 0 -> nil score")
	}
	if s := scaleScore(80, 10); s == nil || *s != 8 {
		t.Fatalf("80%% of 10 = 8, got %v", s)
	}
	if s := scaleScore(57, 10); s == nil || *s != 6 { // 5.7 -> round 6
		t.Fatalf("57%% of 10 rounds to 6, got %v", s)
	}
	if s := scaleScore(100, 10); s == nil || *s != 10 {
		t.Fatalf("100%% -> full points, got %v", s)
	}
}
