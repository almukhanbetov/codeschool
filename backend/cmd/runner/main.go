// Command runner is the code-execution microservice. It is meant to run in a
// dedicated, locked-down container (non-root, no egress network, dropped
// capabilities, read-only rootfs, tmpfs scratch, pid/mem/cpu caps) and is
// never exposed on a host port — only the backend reaches it over the
// internal compose network. It exposes exactly one useful endpoint:
//
//	POST /execute  {language, source, stdin, wallMs}  ->  sandbox.Result
//
// No queueing, no persistence — the backend owns history and grading.
package main

import (
	"context"
	"encoding/json"
	"errors"
	"io/fs"
	"log"
	"net/http"
	"os"
	"os/exec"
	"os/signal"
	"path/filepath"
	"strconv"
	"syscall"
	"time"

	"codeschool/backend/internal/sandbox"
)

// warmGoCache seeds the writable (tmpfs) Go build cache from the read-only
// copy baked into the image, so the first `go run` isn't a full std-lib
// rebuild. Best-effort — a cold cache just means a slow first Go run.
func warmGoCache() {
	dst := os.Getenv("SANDBOX_GOCACHE")
	src := "/opt/gocache-warm"
	if dst == "" {
		return
	}
	if fi, err := os.Stat(src); err != nil || !fi.IsDir() {
		return
	}
	// Only if the destination is empty.
	if entries, err := os.ReadDir(dst); err == nil && len(entries) > 0 {
		return
	}
	if err := os.MkdirAll(dst, 0o777); err != nil {
		return
	}
	err := filepath.WalkDir(src, func(p string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		rel, _ := filepath.Rel(src, p)
		target := filepath.Join(dst, rel)
		if d.IsDir() {
			return os.MkdirAll(target, 0o777)
		}
		b, err := os.ReadFile(p)
		if err != nil {
			return err
		}
		return os.WriteFile(target, b, 0o666)
	})
	if err != nil {
		log.Printf("runner: warm cache copy failed: %v", err)
		return
	}
	// Sanity: a trivial Go build should now be fast.
	_ = exec.Command("true").Run()
	log.Println("runner: Go build cache warmed")
}

type executeRequest struct {
	Language string `json:"language"`
	Source   string `json:"source"`
	Stdin    string `json:"stdin"`
	WallMS   int    `json:"wallMs"`
}

const (
	maxSourceBytes = 256 << 10
	maxStdinBytes  = 64 << 10
	maxConcurrent  = 4
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8090"
	}
	warmGoCache()

	// A small semaphore so a burst of requests can't fork-bomb the container
	// past its pid/cpu budget.
	sem := make(chan struct{}, maxConcurrent)

	mux := http.NewServeMux()
	mux.HandleFunc("/healthz", func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte(`{"status":"ok"}`))
	})
	mux.HandleFunc("/execute", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
			return
		}
		var req executeRequest
		if err := json.NewDecoder(http.MaxBytesReader(w, r.Body, maxSourceBytes+maxStdinBytes+4096)).Decode(&req); err != nil {
			http.Error(w, "bad request", http.StatusBadRequest)
			return
		}
		if len(req.Source) > maxSourceBytes {
			req.Source = req.Source[:maxSourceBytes]
		}
		if len(req.Stdin) > maxStdinBytes {
			req.Stdin = req.Stdin[:maxStdinBytes]
		}

		select {
		case sem <- struct{}{}:
			defer func() { <-sem }()
		case <-time.After(15 * time.Second):
			http.Error(w, "runner busy", http.StatusServiceUnavailable)
			return
		}

		wall := time.Duration(req.WallMS) * time.Millisecond
		res, err := sandbox.Execute(r.Context(), sandbox.Request{
			Language: sandbox.Language(req.Language),
			Source:   req.Source,
			Stdin:    req.Stdin,
			Limits:   sandbox.Limits{Wall: wall},
		})
		if err != nil {
			status := http.StatusBadRequest
			if errors.Is(err, sandbox.ErrToolMissing) {
				status = http.StatusServiceUnavailable
			}
			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(status)
			_ = json.NewEncoder(w).Encode(map[string]string{"error": err.Error()})
			return
		}
		w.Header().Set("Content-Type", "application/json")
		_ = json.NewEncoder(w).Encode(res)
	})

	srv := &http.Server{
		Addr:              ":" + port,
		Handler:           mux,
		ReadHeaderTimeout: 5 * time.Second,
		// no WriteTimeout: a long compile+run can legitimately take ~15s
	}

	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	go func() {
		log.Printf("runner listening on :%s (max %s concurrent)", port, strconv.Itoa(maxConcurrent))
		if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			log.Fatalf("runner: %v", err)
		}
	}()

	<-ctx.Done()
	shutdownCtx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()
	_ = srv.Shutdown(shutdownCtx)
	log.Println("runner stopped")
}
