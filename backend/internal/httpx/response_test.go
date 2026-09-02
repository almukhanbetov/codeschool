package httpx

import (
	"errors"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/gin-gonic/gin"
)

func TestFail_APIError_UsesItsOwnStatusAndCode(t *testing.T) {
	rec := httptest.NewRecorder()
	c, _ := gin.CreateTestContext(rec)

	Fail(c, NotFound("COURSE_NOT_FOUND", "Course not found"))

	if rec.Code != http.StatusNotFound {
		t.Fatalf("expected 404, got %d", rec.Code)
	}
	body := rec.Body.String()
	if !strings.Contains(body, `"code":"COURSE_NOT_FOUND"`) {
		t.Errorf("expected COURSE_NOT_FOUND in body, got %s", body)
	}
}

func TestFail_GenericError_NeverLeaksInternalDetails(t *testing.T) {
	rec := httptest.NewRecorder()
	c, _ := gin.CreateTestContext(rec)

	dbErr := errors.New("pq: password authentication failed for user \"codeschool\" at postgres://secret@host:5432/db")
	Fail(c, dbErr)

	if rec.Code != http.StatusInternalServerError {
		t.Fatalf("expected 500, got %d", rec.Code)
	}
	body := rec.Body.String()
	if strings.Contains(body, "password") || strings.Contains(body, "postgres://") {
		t.Fatalf("response leaked internal error details: %s", body)
	}
	if !strings.Contains(body, `"code":"INTERNAL_ERROR"`) {
		t.Errorf("expected generic INTERNAL_ERROR code, got %s", body)
	}
}
