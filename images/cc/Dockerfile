# syntax=docker/dockerfile:1.7

# =============================================================================
# Distroless CC Image
# =============================================================================
# Base image + C++ runtime libraries (libstdc++, libgcc, libgomp)
#
# Use for: C++ applications, Python with C extensions, Node.js native modules
# Examples: Applications using boost, Qt, or any C++ dependencies
# =============================================================================

ARG BASE_IMAGE=ghcr.io/panteparak/distroless/base
ARG TAG=debian12
ARG DEBIAN_VERSION=bookworm

# =============================================================================
# Stage 1: Package Extractor
# =============================================================================
FROM debian:${DEBIAN_VERSION}-slim AS extractor

ARG DEBIAN_VERSION
ARG TARGETARCH

WORKDIR /extract

# Download and extract C++ runtime packages
# Debian 12 (bookworm): libgomp1, libstdc++6, libgcc-s1, gcc-12-base
# Debian 13 (trixie): libgomp1, libstdc++6, libgcc-s1, gcc-14-base
RUN apt-get update && \
    mkdir -p /tmp/debs && cd /tmp/debs && \
    if [ "${DEBIAN_VERSION}" = "trixie" ]; then \
        apt-get download libgomp1 libstdc++6 libgcc-s1 gcc-14-base; \
    else \
        apt-get download libgomp1 libstdc++6 libgcc-s1 gcc-12-base; \
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
# Stage 2: Final CC Image
# =============================================================================
FROM ${BASE_IMAGE}:${TAG} AS cc

# Build arguments for user configuration
ARG USER=root
ARG UID=0
ARG WORKDIR=/

# Labels
LABEL org.opencontainers.image.title="Distroless CC"
LABEL org.opencontainers.image.description="Base image with C++ runtime libraries"
LABEL org.opencontainers.image.source="https://github.com/panteparak/distroless"

# Copy library files from extractor
COPY --from=extractor /extract/rootfs/lib/ /lib/
COPY --from=extractor /extract/rootfs/usr/lib/ /usr/lib/

# User and workdir are inherited from base image args
USER ${UID}
WORKDIR ${WORKDIR}
