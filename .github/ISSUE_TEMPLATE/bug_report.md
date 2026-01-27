---
name: Bug Report
about: Report a bug in distroless images
title: '[BUG] '
labels: bug
assignees: ''
---

## Description

A clear and concise description of what the bug is.

## Image Details

- **Image**: (e.g., `ghcr.io/panteparak/distroless/python:3.13-nonroot`)
- **Digest**: (run `docker inspect --format='{{index .RepoDigests 0}}' <image>`)
- **Platform**: (e.g., `linux/amd64`, `linux/arm64`)

## Steps to Reproduce

1. Pull image: `docker pull ...`
2. Run container: `docker run ...`
3. See error

## Expected Behavior

What you expected to happen.

## Actual Behavior

What actually happened.

## Dockerfile (if applicable)

```dockerfile
# Your Dockerfile here
```

## Additional Context

Add any other context about the problem here.
