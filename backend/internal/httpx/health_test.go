package httpx

import (
	"context"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
)

func init() {
	gin.SetMode(gin.TestMode)
}

func newTestRouter(checkDB func(ctx context.Context) error) *gin.Engine {
	router := gin.New()
	RegisterHealthRoutes(router, checkDB)
	return router
}

func TestHealth_AlwaysOK(t *testing.T) {
	router := newTestRouter(func(context.Context) error { return errors.New("should not be called") })

	req := httptest.NewRequest(http.MethodGet, "/health", nil)
	rec := httptest.NewRecorder()
	router.ServeHTTP(rec, req)

	if rec.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d", rec.Code)
	}
	if rec.Body.String() != `{"status":"ok"}` {
		t.Errorf("unexpected body: %s", rec.Body.String())
	}
}

func TestHealthReady_DatabaseOK(t *testing.T) {
	router := newTestRouter(func(context.Context) error { return nil })

	req := httptest.NewRequest(http.MethodGet, "/health/ready", nil)
	rec := httptest.NewRecorder()
	router.ServeHTTP(rec, req)

	if rec.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d", rec.Code)
	}
}

func TestHealthReady_DatabaseDown(t *testing.T) {
	router := newTestRouter(func(context.Context) error { return errors.New("connection refused") })

	req := httptest.NewRequest(http.MethodGet, "/health/ready", nil)
	rec := httptest.NewRecorder()
	router.ServeHTTP(rec, req)

	if rec.Code != http.StatusServiceUnavailable {
		t.Fatalf("expected 503, got %d", rec.Code)
	}
}
