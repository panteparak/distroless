# Usage Guide

Detailed usage instructions for distroless images.

## Table of Contents

- [Choosing the Right Base Image](#choosing-the-right-base-image)
- [User Variants](#user-variants)
- [Debug Images](#debug-images)
- [Multi-stage Builds](#multi-stage-builds)
- [Language-specific Examples](#language-specific-examples)

## Choosing the Right Base Image

| Your Application | Recommended Base |
|-----------------|------------------|
| Go (static binary) | `static` |
| Go (with CGO) | `base` or `cc` |
| Rust (static musl) | `static` |
| Rust (with glibc) | `cc` |
| Python | `python:3.x` or `cc` + UV |
| Node.js | `nodejs:xx` |
| Java | `java:xx` |
| C/C++ applications | `cc` |

## User Variants

### Root (default)

```dockerfile
FROM ghcr.io/panteparak/distroless/static:debian12
# User is root (UID 0)
```

### Nonroot (recommended)

```dockerfile
FROM ghcr.io/panteparak/distroless/static:debian12-nonroot
# User is nonroot (UID 65532)
# Workdir is /home/nonroot
```

### Changing ownership for nonroot

```dockerfile
FROM builder AS app
# ... build your app

FROM ghcr.io/panteparak/distroless/static:debian12-nonroot
COPY --from=app --chown=65532:65532 /app /app
```

## Debug Images

Debug images include BusyBox shell for troubleshooting.

```bash
# Run interactive shell
docker run -it ghcr.io/panteparak/distroless/static:debian12-debug /busybox/sh

# Available commands in debug images
/busybox/ls
/busybox/cat
/busybox/wget
/busybox/ps
# ... and many more
```

## Multi-stage Builds

Always use multi-stage builds to keep images minimal:

```dockerfile
# Stage 1: Build
FROM golang:1.23 AS builder
WORKDIR /app
COPY . .
RUN go build -o /server

# Stage 2: Runtime (distroless)
FROM ghcr.io/panteparak/distroless/static:debian12-nonroot
COPY --from=builder /server /server
ENTRYPOINT ["/server"]
```

## Language-specific Examples

See the `/examples` directory for complete examples:

- `examples/python/uv/` - Python with UV package manager
- `examples/python/poetry/` - Python with Poetry
- `examples/nodejs/npm/` - Node.js with npm
- `examples/java/maven/` - Java with Maven
- `examples/go/` - Go static binary
