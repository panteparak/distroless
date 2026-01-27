# syntax=docker/dockerfile:1
# Example: Python application with UV package manager
#
# UV is a fast, modern Python package manager written in Rust.
# This example shows how to use UV for dependency management
# with distroless Python images.
#
# Build:
#   docker build -t myapp .
#
# Run:
#   docker run -p 8080:8080 myapp

# Stage 1: Build with UV
FROM python:3.13-slim AS builder

# Install UV
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

WORKDIR /app

# Copy dependency files first for better caching
COPY pyproject.toml ./

# Create virtual environment and install dependencies
RUN uv venv /app/.venv && \
    . /app/.venv/bin/activate && \
    uv pip install -e .

# Copy application code
COPY main.py ./

# Stage 2: Production image
FROM ghcr.io/panteparak/distroless/python:3.13-debian12-nonroot

# Copy virtual environment from builder
COPY --from=builder /app/.venv /app/.venv
COPY --from=builder /app/main.py /app/

# Set environment
ENV PATH="/app/.venv/bin:$PATH"
ENV PYTHONUNBUFFERED=1

WORKDIR /app

EXPOSE 8080

ENTRYPOINT ["python", "main.py"]
