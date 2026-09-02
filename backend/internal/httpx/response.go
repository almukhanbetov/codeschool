// Package httpx holds the shared HTTP response envelope and error codes used
// by every domain's handler, so the JSON shape is consistent across the API.
package httpx

import (
	"errors"
	"net/http"

	"github.com/gin-gonic/gin"
)

// Envelope wraps every successful response in {"data": ...}.
type Envelope struct {
	Data any `json:"data"`
}

// OK writes a 200 response with the standard {"data": ...} envelope.
func OK(c *gin.Context, data any) {
	c.JSON(http.StatusOK, Envelope{Data: data})
}

// Created writes a 201 response with the standard {"data": ...} envelope.
func Created(c *gin.Context, data any) {
	c.JSON(http.StatusCreated, Envelope{Data: data})
}

// ErrorCode is a stable, machine-readable identifier for an API error.
type ErrorCode string

const (
	CodeNotFound       ErrorCode = "NOT_FOUND"
	CodeInvalidRequest ErrorCode = "INVALID_REQUEST"
	CodeInternal       ErrorCode = "INTERNAL_ERROR"
	CodeUnavailable    ErrorCode = "SERVICE_UNAVAILABLE"
	CodeUnauthorized   ErrorCode = "UNAUTHORIZED"
	CodeForbidden      ErrorCode = "FORBIDDEN"
	CodeConflict       ErrorCode = "CONFLICT"
)

// APIError is a typed, user-safe error. Handlers translate it (or a plain
// error, which becomes CodeInternal) into the {"error": {...}} envelope —
// callers never see raw SQL errors, stack traces, or connection strings.
type APIError struct {
	Status  int
	Code    ErrorCode
	Message string
}

func (e *APIError) Error() string {
	return e.Message
}

func NotFound(code ErrorCode, message string) *APIError {
	return &APIError{Status: http.StatusNotFound, Code: code, Message: message}
}

func BadRequest(code ErrorCode, message string) *APIError {
	return &APIError{Status: http.StatusBadRequest, Code: code, Message: message}
}

func Internal(message string) *APIError {
	return &APIError{Status: http.StatusInternalServerError, Code: CodeInternal, Message: message}
}

func Unauthorized(code ErrorCode, message string) *APIError {
	return &APIError{Status: http.StatusUnauthorized, Code: code, Message: message}
}

func Forbidden(code ErrorCode, message string) *APIError {
	return &APIError{Status: http.StatusForbidden, Code: code, Message: message}
}

func Conflict(code ErrorCode, message string) *APIError {
	return &APIError{Status: http.StatusConflict, Code: code, Message: message}
}

func Unavailable(message string) *APIError {
	return &APIError{Status: http.StatusServiceUnavailable, Code: CodeUnavailable, Message: message}
}

type errorBody struct {
	Code    ErrorCode `json:"code"`
	Message string    `json:"message"`
}

type errorEnvelope struct {
	Error errorBody `json:"error"`
}

// Fail writes the standard {"error": {"code", "message"}} envelope for err.
// A plain (non-*APIError) error is never leaked to the client — it is
// logged server-side and reported as a generic 500 CodeInternal instead.
func Fail(c *gin.Context, err error) {
	var apiErr *APIError
	if errors.As(err, &apiErr) {
		c.JSON(apiErr.Status, errorEnvelope{Error: errorBody{Code: apiErr.Code, Message: apiErr.Message}})
		return
	}

	// Unrecognized error: log the real cause server-side, but never echo it.
	c.Error(err) //nolint:errcheck // recorded for gin's logger, response stays generic
	c.JSON(http.StatusInternalServerError, errorEnvelope{
		Error: errorBody{Code: CodeInternal, Message: "Internal server error"},
	})
}
