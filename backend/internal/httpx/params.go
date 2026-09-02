package httpx

import (
	"strconv"

	"github.com/gin-gonic/gin"
)

// ParseIDParam reads a positive int64 path param (e.g. ":id"). On failure it
// writes the standard 400 error response itself and returns ok=false, so
// callers can just do `id, ok := httpx.ParseIDParam(c, "id"); if !ok { return }`.
func ParseIDParam(c *gin.Context, name string) (int64, bool) {
	raw := c.Param(name)
	id, err := strconv.ParseInt(raw, 10, 64)
	if err != nil || id <= 0 {
		Fail(c, BadRequest("INVALID_ID", "Id must be a positive integer"))
		return 0, false
	}
	return id, true
}
