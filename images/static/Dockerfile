# syntax=docker/dockerfile:1.7

# =============================================================================
# Distroless Static Image
# =============================================================================
# Minimal base image containing only:
# - CA certificates (for HTTPS)
# - Timezone data
# - Base files (os-release, etc.)
# - passwd/group for user management
#
# Use for: Go static binaries, Rust musl binaries, or any fully static executable
# =============================================================================

ARG DEBIAN_VERSION=bookworm
ARG DEBIAN_CODENAME=bookworm

# =============================================================================
# Stage 1: Package Extractor
# =============================================================================
FROM debian:${DEBIAN_VERSION}-slim AS extractor

ARG DEBIAN_CODENAME
ARG TARGETARCH

# Install extraction tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /extract

# Download and extract required packages
# Using current Debian repos (for reproducibility, consider using snapshot.debian.org)
RUN apt-get update && \
    cd /var/cache/apt/archives && \
    apt-get download \
        base-files \
        netbase \
        tzdata \
        ca-certificates \
    && mkdir -p /extract/rootfs \
    && for deb in *.deb; do \
        dpkg-deb -x "$deb" /extract/rootfs; \
    done

# Clean up unnecessary files from extracted packages
RUN rm -rf /extract/rootfs/usr/share/doc/* \
    /extract/rootfs/usr/share/man/* \
    /extract/rootfs/usr/share/info/* \
    /extract/rootfs/usr/share/lintian/* \
    /extract/rootfs/var/lib/dpkg/* \
    /extract/rootfs/var/log/* \
    2>/dev/null || true

# Create required directories with correct permissions
RUN mkdir -p /extract/rootfs/tmp \
    && chmod 1777 /extract/rootfs/tmp \
    && mkdir -p /extract/rootfs/home/nonroot \
    && mkdir -p /extract/rootfs/root

# =============================================================================
# Stage 2: Final Static Image
# =============================================================================
FROM scratch AS static

# Build arguments for user configuration
ARG USER=root
ARG UID=0
ARG WORKDIR=/

# Labels
LABEL org.opencontainers.image.title="Distroless Static"
LABEL org.opencontainers.image.description="Minimal static base image"
LABEL org.opencontainers.image.source="https://github.com/panteparak/distroless"
LABEL org.opencontainers.image.vendor="panteparak"

# Copy extracted Debian files
COPY --from=extractor /extract/rootfs/ /

# Copy static configuration files
COPY files/passwd /etc/passwd
COPY files/group /etc/group
COPY files/nsswitch.conf /etc/nsswitch.conf

# Set ownership for nonroot home directory
# Note: We can't use chown in scratch, so we copy with correct ownership from extractor
COPY --from=extractor --chown=65532:65532 /extract/rootfs/home/nonroot /home/nonroot

# Environment variables
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
    LANG=C.UTF-8

# Set user and working directory
USER ${UID}
WORKDIR ${WORKDIR}

# No entrypoint - this is a base image
