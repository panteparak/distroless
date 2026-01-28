# syntax=docker/dockerfile:1.7

# =============================================================================
# Distroless Base Image
# =============================================================================
# Static image + glibc + OpenSSL
#
# Use for: Applications that need dynamic linking (glibc), SSL/TLS support
# Examples: Most interpreted languages, applications using OpenSSL
# =============================================================================

ARG STATIC_IMAGE=ghcr.io/panteparak/distroless/static
ARG TAG=debian12
ARG DEBIAN_VERSION=bookworm

# =============================================================================
# Stage 1: Package Extractor
# =============================================================================
FROM debian:${DEBIAN_VERSION}-slim AS extractor

ARG DEBIAN_VERSION
ARG TARGETARCH

WORKDIR /extract

# Download and extract libc and SSL packages
# Debian 12 (bookworm): libc6, libssl3
# Debian 13 (trixie): libc6, libssl3t64, libzstd1, zlib1g
RUN apt-get update && \
    mkdir -p /tmp/debs && cd /tmp/debs && \
    if [ "${DEBIAN_VERSION}" = "trixie" ]; then \
        apt-get download libc6 libssl3t64 libzstd1 zlib1g; \
    else \
        apt-get download libc6 libssl3; \
    fi && \
    mkdir -p /extract/rootfs && \
    for deb in *.deb; do \
        dpkg-deb -x "$deb" /extract/rootfs; \
    done

# Clean up unnecessary files
RUN rm -rf /extract/rootfs/usr/share/doc/* \
    /extract/rootfs/usr/share/man/* \
    /extract/rootfs/var/lib/dpkg/* \
    2>/dev/null || true

# =============================================================================
# Stage 2: Final Base Image
# =============================================================================
FROM ${STATIC_IMAGE}:${TAG} AS base

# Build arguments for user configuration
ARG USER=root
ARG UID=0
ARG WORKDIR=/

# Labels
LABEL org.opencontainers.image.title="Distroless Base"
LABEL org.opencontainers.image.description="Static image with glibc and OpenSSL"
LABEL org.opencontainers.image.source="https://github.com/panteparak/distroless"

# Copy library files from extractor
# Only copy the lib directories to avoid overwriting static files
COPY --from=extractor /extract/rootfs/lib/ /lib/
COPY --from=extractor /extract/rootfs/usr/lib/ /usr/lib/

# User and workdir are inherited from base image args
USER ${UID}
WORKDIR ${WORKDIR}
