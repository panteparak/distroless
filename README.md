# Distroless Container Images

Minimal, secure container images based on Debian - no shell, no package manager, just your application.

## Overview

This project provides distroless container images inspired by [GoogleContainerTools/distroless](https://github.com/GoogleContainerTools/distroless), built using multi-stage Dockerfiles instead of Bazel.

### Image Hierarchy

```
scratch
   |
static (ca-certs, tzdata, passwd/group)
   |
base (+ libc6, libssl3)
   |
cc (+ libstdc++, libgcc)
   |
+-- python (3.8-3.13)
+-- nodejs (20, 22, 24)
|
base-nossl (libc6 only)
   |
java (17, 21 Temurin JRE)
```

## Quick Start

### Go Application (Static Binary)

```dockerfile
FROM golang:1.23 AS builder
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o /server

FROM ghcr.io/panteparak/distroless/static:debian12-nonroot
COPY --from=builder /server /server
ENTRYPOINT ["/server"]
```

### Python with UV

```dockerfile
FROM ghcr.io/panteparak/distroless/cc:debian12 AS builder
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv
WORKDIR /app
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev

FROM ghcr.io/panteparak/distroless/cc:debian12-nonroot
COPY --from=builder /app /app
ENV PATH="/app/.venv/bin:$PATH"
ENTRYPOINT ["python", "main.py"]
```

### Node.js

```dockerfile
FROM node:22-slim AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev
COPY . .

FROM ghcr.io/panteparak/distroless/nodejs:22-debian12-nonroot
COPY --from=builder /app /app
ENTRYPOINT ["/nodejs/bin/node", "/app/index.js"]
```

### Java with Maven

```dockerfile
FROM maven:3.9-eclipse-temurin-21 AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn package -DskipTests

FROM ghcr.io/panteparak/distroless/java:21-nonroot
COPY --from=builder /app/target/*.jar /app/app.jar
ENTRYPOINT ["/usr/bin/java", "-jar", "/app/app.jar"]
```

## Available Images

| Image | Description | Tags |
|-------|-------------|------|
| `static` | Minimal base (ca-certs, tzdata) | `debian12`, `debian12-nonroot`, `debian12-debug` |
| `base` | Static + libc6 + libssl3 | `debian12`, `debian12-nonroot`, `debian12-debug` |
| `cc` | Base + libstdc++ (for C++ extensions) | `debian12`, `debian12-nonroot`, `debian12-debug` |
| `python` | CC + Python runtime | `3.8`, `3.9`, `3.10`, `3.11`, `3.12`, `3.13` + `-nonroot` |
| `nodejs` | CC + Node.js | `20`, `22`, `24` + `-debian12` + `-nonroot` |
| `java` | Base + Temurin JRE | `17`, `21` + `-nonroot` |

### Tag Format

```
ghcr.io/panteparak/distroless/{image}:{version}-{debian}-{variant}
```

**Variants:**
- (none) - root user
- `-nonroot` - UID 65532
- `-debug` - includes busybox shell
- `-debug-nonroot` - debug + nonroot

## User Variants

| User | UID | Home | Use Case |
|------|-----|------|----------|
| root | 0 | / | Privileged operations |
| nonroot | 65532 | /home/nonroot | **Recommended** for production |

## Debug Images

Debug images include BusyBox for troubleshooting:

```bash
# Interactive shell
docker run -it ghcr.io/panteparak/distroless/static:debian12-debug

# Debug a running container
docker exec -it <container> /busybox/sh
```

## Security

### Supply Chain Security

All images include:
- **SBOM** (Software Bill of Materials) in SPDX format
- **Cosign signatures** (keyless, OIDC-based)

```bash
# Verify signature
cosign verify ghcr.io/panteparak/distroless/static:debian12

# Verify SBOM attestation
cosign verify-attestation --type spdxjson ghcr.io/panteparak/distroless/static:debian12
```

### Why Distroless?

- **Smaller attack surface**: No shell, no package manager
- **Fewer CVEs**: Only runtime dependencies included
- **Immutable**: No way to install packages at runtime
- **Compliance**: Clean SBOM for auditing

## Building Locally

```bash
# Install dependencies
brew install hadolint shellcheck pre-commit
pre-commit install

# Build all base images
make build

# Build with debug
make build-debug

# Run tests
make test

# Lint
make lint
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes
4. Run `make lint` and `make test`
5. Submit a pull request

## License

Apache 2.0 - See [LICENSE](LICENSE)

## Acknowledgments

- [GoogleContainerTools/distroless](https://github.com/GoogleContainerTools/distroless) - Original inspiration
- [Debian](https://www.debian.org/) - Base packages
- [Adoptium](https://adoptium.net/) - Temurin JRE
