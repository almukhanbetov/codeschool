# --- build stage ---
FROM golang:1.26-alpine AS build
WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 go build -o /out/api ./cmd/api

# --- goose binary, copied into the final image so migrations can run there too ---
FROM golang:1.26-alpine AS goose
RUN CGO_ENABLED=0 go install github.com/pressly/goose/v3/cmd/goose@latest

# --- runtime stage ---
FROM alpine:3.20
RUN apk add --no-cache ca-certificates
WORKDIR /app

COPY --from=build /out/api ./api
COPY --from=goose /go/bin/goose /usr/local/bin/goose
COPY migrations ./migrations

EXPOSE 8080
ENTRYPOINT ["./api"]
