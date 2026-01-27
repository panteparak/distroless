# syntax=docker/dockerfile:1.7

# =============================================================================
# Shared Debug Dockerfile
# =============================================================================
# This single Dockerfile can create debug variants of ANY distroless image.
# It adds BusyBox for debugging and troubleshooting.
#
# Usage:
#   # Debug for static image
#   docker build \
#     --build-arg BASE_IMAGE=ghcr.io/panteparak/distroless/static \
#     --build-arg TAG=debian12 \
#     -f images/debug/Dockerfile \
#     -t static:debian12-debug .
#
#   # Debug for Python image
#   docker build \
#     --build-arg BASE_IMAGE=ghcr.io/panteparak/distroless/python \
#     --build-arg TAG=3.13-debian12-nonroot \
#     -f images/debug/Dockerfile \
#     -t python:3.13-debug-nonroot .
#
# This eliminates the need for separate Dockerfile.debug files in each image
# directory, reducing duplication and maintenance burden.
# =============================================================================

ARG BASE_IMAGE
ARG TAG

# =============================================================================
# Stage 1: Get BusyBox
# =============================================================================
# Build BusyBox once, reused for all debug images via Docker layer caching.
FROM debian:bookworm-slim AS busybox

# Install busybox-static (statically linked, works on any base image)
RUN apt-get update && apt-get install -y --no-install-recommends \
    busybox-static \
    && rm -rf /var/lib/apt/lists/*

# Create busybox directory with all applets
RUN mkdir -p /busybox \
    && cp /bin/busybox /busybox/busybox \
    && chmod +x /busybox/busybox \
    && /busybox/busybox --install -s /busybox

# =============================================================================
# Stage 2: Create Debug Image
# =============================================================================
# Inherit from the production image and add debugging tools.
FROM ${BASE_IMAGE}:${TAG}

# Copy BusyBox applets
COPY --from=busybox /busybox /busybox

# Add busybox to PATH
ENV PATH="$PATH:/busybox"

# Override entrypoint with shell for interactive debugging
ENTRYPOINT ["/busybox/sh"]
