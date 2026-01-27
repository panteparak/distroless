# syntax=docker/dockerfile:1
# Example: Node.js application with npm
#
# This example shows how to use npm with distroless Node.js images.
#
# Build:
#   docker build -t myapp .
#
# Run:
#   docker run -p 8080:8080 myapp

# Stage 1: Build with npm
FROM node:22-slim AS builder

WORKDIR /app

# Copy package files first for better caching
COPY package*.json ./

# Install production dependencies only
RUN npm ci --omit=dev

# Copy application code
COPY index.js ./

# Stage 2: Production image
FROM ghcr.io/panteparak/distroless/nodejs:22-debian12-nonroot

# Copy application from builder
COPY --from=builder /app /app

WORKDIR /app

EXPOSE 8080

# Use the full path to node binary
ENTRYPOINT ["/nodejs/bin/node", "index.js"]
