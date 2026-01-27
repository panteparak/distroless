# syntax=docker/dockerfile:1
# Example: Go static binary with distroless
#
# Go is ideal for distroless because CGO_ENABLED=0 produces fully static
# binaries that run on the minimal static base image.
#
# Build:
#   docker build -t myapp .
#
# Run:
#   docker run -p 8080:8080 myapp

# Stage 1: Build with Go
FROM golang:1.23 AS builder

WORKDIR /app

# Copy go.mod first for better caching
COPY go.mod ./

# Download dependencies (if any)
RUN go mod download || true

# Copy source code
COPY main.go ./

# Build static binary
# CGO_ENABLED=0 - produce static binary without libc dependency
# -ldflags="-s -w" - strip debug info for smaller binary
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /app/server

# Stage 2: Production image
# Use static image since Go binary is fully static
FROM ghcr.io/panteparak/distroless/static:debian12-nonroot

# Copy binary from builder
COPY --from=builder /app/server /server

EXPOSE 8080

# Run the application
ENTRYPOINT ["/server"]
