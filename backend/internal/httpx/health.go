package httpx

import (
	"context"
	"net/http"

	"github.com/gin-gonic/gin"
)

// RegisterHealthRoutes mounts GET /health and GET /health/ready.
// checkDB should run a trivial query (e.g. SELECT 1) and return an error if
// the database is unreachable.
func RegisterHealthRoutes(router gin.IRouter, checkDB func(ctx context.Context) error) {
	router.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"status": "ok"})
	})

	router.GET("/health/ready", func(c *gin.Context) {
		if err := checkDB(c.Request.Context()); err != nil {
			c.JSON(http.StatusServiceUnavailable, gin.H{"status": "unavailable", "database": "error"})
			return
		}
		c.JSON(http.StatusOK, gin.H{"status": "ready", "database": "ok"})
	})
}
