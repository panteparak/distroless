# Building Images Locally

Instructions for building distroless images from source.

## Prerequisites

- Docker with BuildKit enabled
- `docker buildx` for multi-arch builds
- `hadolint` for Dockerfile linting
- `shellcheck` for shell script linting
- `pre-commit` for git hooks

### Installing Prerequisites

```bash
# macOS
brew install hadolint shellcheck pre-commit

# Ubuntu/Debian
apt-get install -y hadolint shellcheck
pip install pre-commit
```

## Quick Build

```bash
# Build all base images (static, base, cc)
make build

# Build with debug variants
make build-debug

# Build specific image
make build-static
make build-base
make build-cc
```

## Development Build

For faster iteration during development:

```bash
# Build for local architecture only
make dev-static

# Test with debug shell
make shell-debug
```

## Multi-architecture Build

```bash
# Set up buildx
docker buildx create --name multiarch --use

# Build for amd64 and arm64
make build PLATFORMS=linux/amd64,linux/arm64
```

## Testing

```bash
# Run all tests
make test

# Run linting
make lint

# Install pre-commit hooks
make install-hooks
```

## Customization

### Using a Different Registry

```bash
make build REGISTRY=my-registry.com IMAGE_PREFIX=myorg/distroless
```

### Building for Different Debian Version

```bash
make build DEBIAN_VERSION=debian13
```

## Troubleshooting

### Build fails with "no space left on device"

```bash
docker system prune -a
```

### Multi-arch build fails

Ensure QEMU is set up:

```bash
docker run --privileged --rm tonistiigi/binfmt --install all
```
