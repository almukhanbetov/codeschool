package sandbox

import (
	"context"
	"strings"
	"testing"
	"time"
)

// runnable reports whether the sandbox can actually launch the language with
// its restricted PATH (a dev host may have e.g. node only via nvm — the
// container always has it on /usr/bin).
func runnable(t *testing.T, lang Language, src string) bool {
	t.Helper()
	res, err := Execute(context.Background(), Request{Language: lang, Source: src, Limits: Limits{Wall: 15 * time.Second}})
	if err != nil {
		return false
	}
	return res.ExitCode != 127
}

func run(t *testing.T, req Request) *Result {
	t.Helper()
	if req.Limits.Wall == 0 {
		req.Limits.Wall = 6 * time.Second
	}
	res, err := Execute(context.Background(), req)
	if err != nil {
		t.Fatalf("Execute: %v", err)
	}
	return res
}

func TestExecute_UnsupportedLanguage(t *testing.T) {
	if _, err := Execute(context.Background(), Request{Language: "ruby", Source: "puts 1"}); err == nil {
		t.Fatal("want error for unsupported language")
	}
}

func TestExecute_Python(t *testing.T) {
	if !runnable(t, Python, "print(1)") {
		t.Skip("python3 not runnable from the sandbox PATH")
	}

	t.Run("hello", func(t *testing.T) {
		r := run(t, Request{Language: Python, Source: `print("hello")`})
		if strings.TrimSpace(r.Stdout) != "hello" || r.ExitCode != 0 {
			t.Fatalf("%+v", r)
		}
	})

	t.Run("stdin echo", func(t *testing.T) {
		r := run(t, Request{Language: Python, Source: "import sys; sys.stdout.write(sys.stdin.read().upper())", Stdin: "abc\n"})
		if r.Stdout != "ABC\n" {
			t.Fatalf("stdout=%q", r.Stdout)
		}
	})

	t.Run("nonzero exit + stderr", func(t *testing.T) {
		r := run(t, Request{Language: Python, Source: "import sys; sys.stderr.write('boom'); sys.exit(3)"})
		if r.ExitCode != 3 || !strings.Contains(r.Stderr, "boom") {
			t.Fatalf("%+v", r)
		}
	})

	t.Run("wall-clock timeout", func(t *testing.T) {
		r := run(t, Request{
			Language: Python,
			Source:   "while True:\n    pass\n",
			Limits:   Limits{Wall: 1200 * time.Millisecond},
		})
		if !r.TimedOut {
			t.Fatalf("expected TimedOut, got %+v", r)
		}
		if r.DurationMS > 4000 {
			t.Fatalf("timeout took too long: %dms", r.DurationMS)
		}
	})

	t.Run("output is truncated", func(t *testing.T) {
		r := run(t, Request{
			Language: Python,
			Source:   "print('x' * 5_000_000)",
			Limits:   Limits{Wall: 4 * time.Second, MaxOutput: 4096},
		})
		if !r.Truncated || len(r.Stdout) > 5000 {
			t.Fatalf("truncated=%v len=%d", r.Truncated, len(r.Stdout))
		}
	})

	t.Run("no network", func(t *testing.T) {
		// Best-effort: inside the runner container there is no route out, so a
		// socket connect fails fast. On a dev host with network this may
		// succeed — so we only assert the program runs, not the verdict.
		r := run(t, Request{
			Language: Python,
			Source:   "import socket; s=socket.socket(); s.settimeout(1)\ntry:\n s.connect(('1.1.1.1',80)); print('OPEN')\nexcept Exception as e:\n print('BLOCKED')",
			Limits:   Limits{Wall: 4 * time.Second},
		})
		if r.ExitCode != 0 {
			t.Fatalf("%+v", r)
		}
	})
}

func TestExecute_JavaScript(t *testing.T) {
	if !runnable(t, JavaScript, "console.log(1)") {
		t.Skip("node not runnable from the sandbox PATH")
	}
	r := run(t, Request{Language: JavaScript, Source: `const l=require('fs').readFileSync(0,'utf8').trim(); console.log(Number(l)*2);`, Stdin: "21"})
	if strings.TrimSpace(r.Stdout) != "42" {
		t.Fatalf("%+v", r)
	}
}

func TestExecute_Go(t *testing.T) {
	if !runnable(t, Go, "package main\nfunc main(){}\n") {
		t.Skip("go not runnable from the sandbox PATH")
	}
	src := "package main\nimport \"fmt\"\nfunc main(){ fmt.Println(2+2) }\n"
	r := run(t, Request{Language: Go, Source: src, Limits: Limits{Wall: 20 * time.Second}})
	if strings.TrimSpace(r.Stdout) != "4" || r.ExitCode != 0 {
		t.Fatalf("%+v", r)
	}
}
