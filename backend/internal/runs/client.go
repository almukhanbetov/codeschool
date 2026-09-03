package runs

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

// execResult mirrors sandbox.Result (kept local so this package does not
// import the sandbox package — the two run in different processes).
type execResult struct {
	Stdout     string `json:"stdout"`
	Stderr     string `json:"stderr"`
	ExitCode   int    `json:"exitCode"`
	TimedOut   bool   `json:"timedOut"`
	Truncated  bool   `json:"truncated"`
	DurationMS int64  `json:"durationMs"`
}

// RunnerClient talks to the sandboxed execution service over HTTP.
type RunnerClient struct {
	baseURL string
	http    *http.Client
}

// NewRunnerClient returns a client, or nil when baseURL is empty (runner
// disabled).
func NewRunnerClient(baseURL string) *RunnerClient {
	if baseURL == "" {
		return nil
	}
	return &RunnerClient{
		baseURL: baseURL,
		http:    &http.Client{Timeout: 30 * time.Second},
	}
}

type execRequest struct {
	Language string `json:"language"`
	Source   string `json:"source"`
	Stdin    string `json:"stdin"`
	WallMS   int    `json:"wallMs"`
}

// Execute forwards one program to the runner. A transport failure or a 5xx is
// reported as ErrRunnerUnavailable.
func (c *RunnerClient) Execute(ctx context.Context, language, source, stdin string, wallMS int) (execResult, error) {
	body, _ := json.Marshal(execRequest{Language: language, Source: source, Stdin: stdin, WallMS: wallMS})
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, c.baseURL+"/execute", bytes.NewReader(body))
	if err != nil {
		return execResult{}, err
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := c.http.Do(req)
	if err != nil {
		return execResult{}, fmt.Errorf("%w: %v", ErrRunnerUnavailable, err)
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 500 {
		return execResult{}, fmt.Errorf("%w: runner returned %d", ErrRunnerUnavailable, resp.StatusCode)
	}
	if resp.StatusCode != http.StatusOK {
		var e struct {
			Error string `json:"error"`
		}
		_ = json.NewDecoder(resp.Body).Decode(&e)
		if e.Error == "" {
			e.Error = fmt.Sprintf("runner returned %d", resp.StatusCode)
		}
		return execResult{}, invalid(e.Error)
	}

	var out execResult
	if err := json.NewDecoder(resp.Body).Decode(&out); err != nil {
		return execResult{}, fmt.Errorf("%w: bad runner response: %v", ErrRunnerUnavailable, err)
	}
	return out, nil
}
