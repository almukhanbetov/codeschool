// Package config loads runtime configuration from environment variables.
package config

import (
	"fmt"
	"os"
	"strings"
	"time"
)

type Config struct {
	AppEnv             string
	Port               string
	DatabaseURL        string
	CORSAllowedOrigins []string

	JWTSecret     string
	JWTAccessTTL  time.Duration
	JWTRefreshTTL time.Duration

	// RunnerURL is the base URL of the code-execution service (e.g.
	// http://runner:8090). Empty disables the code runner — its endpoints
	// then return 503.
	RunnerURL string

	// PublicBaseURL is the public origin of the frontend, used to build the
	// certificate verification URLs printed (and QR-encoded) on issued
	// certificate PDFs, e.g. https://codeschool.example.
	PublicBaseURL string
}

func Load() (*Config, error) {
	databaseURL := os.Getenv("DATABASE_URL")
	if databaseURL == "" {
		return nil, fmt.Errorf("DATABASE_URL is required")
	}

	port := getEnvDefault("PORT", "8080")
	appEnv := getEnvDefault("APP_ENV", "development")

	origins := getEnvDefault("CORS_ALLOWED_ORIGINS", "http://localhost:3000")
	allowedOrigins := splitAndTrim(origins)

	publicBaseURL := os.Getenv("PUBLIC_BASE_URL")
	if publicBaseURL == "" && len(allowedOrigins) > 0 {
		publicBaseURL = allowedOrigins[0]
	}
	if publicBaseURL == "" {
		publicBaseURL = "http://localhost:3000"
	}
	publicBaseURL = strings.TrimRight(publicBaseURL, "/")

	jwtSecret := os.Getenv("JWT_SECRET")
	if jwtSecret == "" {
		return nil, fmt.Errorf("JWT_SECRET is required")
	}

	accessTTL, err := parseDurationDefault("JWT_ACCESS_TTL", 15*time.Minute)
	if err != nil {
		return nil, err
	}
	refreshTTL, err := parseDurationDefault("JWT_REFRESH_TTL", 720*time.Hour)
	if err != nil {
		return nil, err
	}

	return &Config{
		AppEnv:             appEnv,
		Port:               port,
		DatabaseURL:        databaseURL,
		CORSAllowedOrigins: allowedOrigins,
		JWTSecret:          jwtSecret,
		JWTAccessTTL:       accessTTL,
		JWTRefreshTTL:      refreshTTL,
		RunnerURL:          strings.TrimRight(os.Getenv("RUNNER_URL"), "/"),
		PublicBaseURL:      publicBaseURL,
	}, nil
}

func (c *Config) IsProduction() bool {
	return c.AppEnv == "production"
}

func getEnvDefault(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func parseDurationDefault(key string, fallback time.Duration) (time.Duration, error) {
	raw := os.Getenv(key)
	if raw == "" {
		return fallback, nil
	}
	d, err := time.ParseDuration(raw)
	if err != nil {
		return 0, fmt.Errorf("%s must be a Go duration (e.g. 15m, 720h): %w", key, err)
	}
	if d <= 0 {
		return 0, fmt.Errorf("%s must be positive", key)
	}
	return d, nil
}

func splitAndTrim(s string) []string {
	parts := strings.Split(s, ",")
	out := make([]string, 0, len(parts))
	for _, p := range parts {
		p = strings.TrimSpace(p)
		if p != "" {
			out = append(out, p)
		}
	}
	return out
}
