# syntax=docker/dockerfile:1
# Example: Node.js application with pnpm
#
# pnpm is a fast, disk-efficient package manager that uses a content-addressable
# store and symbolic links to deduplicate dependencies.
#
# Build:
#   docker build -t myapp .
#
# Run:
#   docker run -p 8080:8080 myapp

# Stage 1: Build with pnpm
FROM node:22-slim AS builder

# Install pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /app

# Copy package files first for better caching
COPY package.json ./

# Install production dependencies only
RUN pnpm install --prod --frozen-lockfile || pnpm install --prod

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
