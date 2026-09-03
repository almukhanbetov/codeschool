// Package sandbox executes a single short-lived program (Python / JavaScript /
// Go) and captures its output. It is the innermost layer of the code runner:
// it assumes it is already running inside a locked-down container (non-root,
// no network, dropped capabilities, read-only rootfs, tmpfs scratch, pid /
// memory / cpu caps) and adds the per-execution guards:
//
//   - a hard wall-clock timeout that SIGKILLs the whole process group;
//   - a CPU-seconds rlimit and a file-size rlimit (ulimit), plus an address
//     space cap for interpreters that honor it;
//   - bounded stdin and bounded stdout/stderr capture (the rest is discarded);
//   - a fresh scratch directory, wiped afterwards, and a stripped environment.
//
// It NEVER executes anything but the four fixed interpreter/compiler commands
// below — the user only ever controls a source file and stdin.
package sandbox

import (
	"bytes"
	"context"
	"errors"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"syscall"
	"time"
)

// Language is one of the supported runtimes.
type Language string

const (
	Python     Language = "python"
	JavaScript Language = "javascript"
	Go         Language = "go"
)

// Limits are the hard caps applied to one execution. Zero values fall back to
// the defaults in DefaultLimits().
type Limits struct {
	Wall         time.Duration // wall-clock timeout
	CPU          time.Duration // CPU-time rlimit (RLIMIT_CPU, whole seconds)
	AddressSpace int64         // RLIMIT_AS in bytes (interpreters only); 0 = unset
	MaxOutput    int64         // bytes captured per stream before truncation
	MaxStdin     int64         // bytes of stdin forwarded
}

// DefaultLimits is a conservative profile for classroom exercises.
func DefaultLimits() Limits {
	return Limits{
		Wall:         5 * time.Second,
		CPU:          6 * time.Second,
		AddressSpace: 512 << 20, // 512 MiB
		MaxOutput:    64 << 10,  // 64 KiB per stream
		MaxStdin:     64 << 10,
	}
}

func (l Limits) withDefaults() Limits {
	d := DefaultLimits()
	if l.Wall <= 0 {
		l.Wall = d.Wall
	}
	if l.Wall > 20*time.Second {
		l.Wall = 20 * time.Second
	}
	if l.CPU <= 0 {
		l.CPU = l.Wall + time.Second
	}
	if l.MaxOutput <= 0 {
		l.MaxOutput = d.MaxOutput
	}
	if l.MaxStdin <= 0 {
		l.MaxStdin = d.MaxStdin
	}
	return l
}

// Request is one execution.
type Request struct {
	Language Language
	Source   string
	Stdin    string
	Limits   Limits
}

// Result is the outcome of one execution.
type Result struct {
	Stdout     string `json:"stdout"`
	Stderr     string `json:"stderr"`
	ExitCode   int    `json:"exitCode"`
	TimedOut   bool   `json:"timedOut"`
	Truncated  bool   `json:"truncated"`
	DurationMS int64  `json:"durationMs"`
}

var (
	// ErrUnsupportedLanguage — the language is not one of the fixed set.
	ErrUnsupportedLanguage = errors.New("unsupported language")
	// ErrToolMissing — the interpreter/compiler is not installed in the image.
	ErrToolMissing = errors.New("language toolchain not available")
)

type langSpec struct {
	filename string
	// command is the argv run under `sh -c "<ulimits>; exec <command>"`.
	command func(dir string) string
	// probe is the binary that must exist on PATH.
	probe string
	// capAddressSpace: apply RLIMIT_AS (safe for interpreters, breaks VMs
	// that reserve huge virtual mappings).
	capAddressSpace bool
	// maxFileBytes is the RLIMIT_FSIZE cap. Interpreters need only a few MiB;
	// `go run` writes multi-MiB compilation archives, so Go gets more room.
	maxFileBytes int64
	env          func(dir string) []string
}

func specFor(l Language) (langSpec, bool) {
	switch l {
	case Python:
		return langSpec{
			filename:        "main.py",
			probe:           "python3",
			capAddressSpace: true,
			maxFileBytes:    8 << 20,
			command:         func(string) string { return "python3 -I -B main.py" },
			env:             func(dir string) []string { return nil },
		}, true
	case JavaScript:
		return langSpec{
			filename:     "main.js",
			probe:        "node",
			maxFileBytes: 16 << 20,
			command:      func(string) string { return "node --max-old-space-size=256 main.js" },
			env:          func(string) []string { return nil },
		}, true
	case Go:
		return langSpec{
			filename:     "main.go",
			probe:        "go",
			maxFileBytes: 512 << 20, // `go run` writes large compilation archives
			command:      func(string) string { return "go run main.go" },
			env: func(dir string) []string {
				gocache := os.Getenv("SANDBOX_GOCACHE") // shared warm cache in the container
				if gocache == "" {
					gocache = filepath.Join(dir, ".gocache")
				}
				return []string{
					"GOCACHE=" + gocache,
					"GOPATH=" + filepath.Join(dir, ".gopath"),
					"GOFLAGS=-mod=mod",
					"GOTOOLCHAIN=local", // never try to fetch a toolchain (offline)
					"CGO_ENABLED=0",
				}
			},
		}, true
	default:
		return langSpec{}, false
	}
}

// scratchRoot is where per-run directories are created. In the runner
// container this is an exec-capable tmpfs (SANDBOX_SCRATCH); on a dev host it
// falls back to the system temp dir. Overridable in tests.
var scratchRoot = firstNonEmpty(os.Getenv("SANDBOX_SCRATCH"), os.TempDir())

func firstNonEmpty(a, b string) string {
	if a != "" {
		return a
	}
	return b
}

// Execute runs one program. It always returns a *Result for a program that
// ran (even one that crashed or timed out); it returns an error only for
// setup failures (bad language, missing toolchain, cannot write scratch).
func Execute(ctx context.Context, req Request) (*Result, error) {
	spec, ok := specFor(req.Language)
	if !ok {
		return nil, fmt.Errorf("%w: %q", ErrUnsupportedLanguage, req.Language)
	}
	if _, err := exec.LookPath(spec.probe); err != nil {
		return nil, fmt.Errorf("%w: %s", ErrToolMissing, spec.probe)
	}

	lim := req.Limits.withDefaults()

	dir, err := os.MkdirTemp(scratchRoot, "csrun-")
	if err != nil {
		return nil, fmt.Errorf("scratch dir: %w", err)
	}
	defer os.RemoveAll(dir)
	if err := os.WriteFile(filepath.Join(dir, spec.filename), []byte(req.Source), 0o600); err != nil {
		return nil, fmt.Errorf("write source: %w", err)
	}

	stdin := req.Stdin
	if int64(len(stdin)) > lim.MaxStdin {
		stdin = stdin[:lim.MaxStdin]
	}

	// ulimit prefix (busybox/ash + bash both accept these).
	fsize := spec.maxFileBytes
	if fsize <= 0 {
		fsize = 8 << 20
	}
	var ul strings.Builder
	fmt.Fprintf(&ul, "ulimit -t %d 2>/dev/null; ", int(lim.CPU.Seconds())+1)
	fmt.Fprintf(&ul, "ulimit -f %d 2>/dev/null; ", fsize/512) // 512-byte blocks
	ul.WriteString("ulimit -c 0 2>/dev/null; ")
	if spec.capAddressSpace && lim.AddressSpace > 0 {
		fmt.Fprintf(&ul, "ulimit -v %d 2>/dev/null; ", lim.AddressSpace/1024)
	}
	script := ul.String() + "exec " + spec.command(dir)

	cctx, cancel := context.WithTimeout(ctx, lim.Wall)
	defer cancel()

	cmd := exec.CommandContext(cctx, "sh", "-c", script)
	cmd.Dir = dir
	cmd.Env = append([]string{
		"PATH=/usr/local/go/bin:/usr/local/bin:/usr/bin:/bin",
		"HOME=" + dir,
		"TMPDIR=" + dir,
		"LANG=C.UTF-8",
		"LC_ALL=C.UTF-8",
	}, spec.env(dir)...)
	cmd.Stdin = strings.NewReader(stdin)

	outBuf := &capped{limit: lim.MaxOutput}
	errBuf := &capped{limit: lim.MaxOutput}
	cmd.Stdout = outBuf
	cmd.Stderr = errBuf

	// New process group so a timeout kill takes down the whole tree.
	cmd.SysProcAttr = &syscall.SysProcAttr{Setpgid: true}
	cmd.Cancel = func() error {
		if cmd.Process != nil {
			_ = syscall.Kill(-cmd.Process.Pid, syscall.SIGKILL)
		}
		return os.ErrProcessDone
	}
	cmd.WaitDelay = 2 * time.Second

	start := time.Now()
	runErr := cmd.Run()
	dur := time.Since(start)

	res := &Result{
		Stdout:     outBuf.String(),
		Stderr:     errBuf.String(),
		Truncated:  outBuf.truncated || errBuf.truncated,
		DurationMS: dur.Milliseconds(),
	}

	switch {
	case cctx.Err() == context.DeadlineExceeded:
		res.TimedOut = true
		res.ExitCode = -1
	case runErr == nil:
		res.ExitCode = 0
	default:
		var ee *exec.ExitError
		if errors.As(runErr, &ee) {
			res.ExitCode = ee.ExitCode()
			if res.ExitCode < 0 { // killed by signal
				if ws, ok := ee.Sys().(syscall.WaitStatus); ok && ws.Signaled() {
					res.Stderr = appendLine(res.Stderr, "process killed by signal: "+ws.Signal().String())
				}
			}
		} else {
			return nil, fmt.Errorf("run %s: %w", req.Language, runErr)
		}
	}
	return res, nil
}

func appendLine(s, line string) string {
	if s != "" && !strings.HasSuffix(s, "\n") {
		s += "\n"
	}
	return s + line + "\n"
}

// capped is an io.Writer that keeps at most `limit` bytes and then drops the
// rest, flagging truncation.
type capped struct {
	buf       bytes.Buffer
	limit     int64
	truncated bool
}

func (c *capped) Write(p []byte) (int, error) {
	remaining := c.limit - int64(c.buf.Len())
	if remaining <= 0 {
		c.truncated = true
		return len(p), nil
	}
	if int64(len(p)) > remaining {
		c.buf.Write(p[:remaining])
		c.truncated = true
		return len(p), nil
	}
	return c.buf.Write(p)
}

func (c *capped) String() string { return c.buf.String() }
