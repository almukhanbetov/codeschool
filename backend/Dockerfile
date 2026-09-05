# syntax=docker/dockerfile:1
#
# Backend API image. Multi-stage, statically linked (CGO_ENABLED=0), minimal
# alpine runtime, runs as a non-root user. The same image also carries the
# `goose` binary + the SQL migrations so the `migrate` service can reuse it
# (docker-compose.prod.yml runs it with an overridden entrypoint). No Go
# compiler, no source, and no secrets are baked in.

# --- build stage ---
FROM golang:1.26-alpine AS build
WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download

COPY . .
# CGO stays disabled -> a fully static binary that runs on a bare alpine (or
# scratch/distroless). -trimpath + reproducible ldflags keep the build deterministic.
RUN CGO_ENABLED=0 GOFLAGS=-mod=mod go build -trimpath -ldflags="-s -w -buildid=" -o /out/api ./cmd/api

# --- goose binary, copied into the final image so migrations can run there too ---
FROM golang:1.26-alpine AS goose
ENV CGO_ENABLED=0
RUN go install github.com/pressly/goose/v3/cmd/goose@v3.28.0

# --- runtime stage ---
FROM alpine:3.20
# ca-certificates: outbound TLS (e.g. future integrations). wget (busybox) is
# already present and is used by the compose healthcheck to hit /health/ready.
RUN apk add --no-cache ca-certificates \
    && adduser -D -H -u 10001 appuser
WORKDIR /app

COPY --from=build /out/api ./api
COPY --from=goose /go/bin/goose /usr/local/bin/goose
COPY migrations ./migrations

USER appuser
EXPOSE 8080
ENTRYPOINT ["./api"]
