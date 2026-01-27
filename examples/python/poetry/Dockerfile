# syntax=docker/dockerfile:1
# Example: Python application with Poetry package manager
#
# Poetry is a popular Python dependency management and packaging tool.
# This example shows how to use Poetry with distroless Python images.
#
# Build:
#   docker build -t myapp .
#
# Run:
#   docker run -p 8080:8080 myapp

# Stage 1: Build with Poetry
FROM python:3.13-slim AS builder

# Install Poetry
ENV POETRY_HOME=/opt/poetry
ENV POETRY_VIRTUALENVS_IN_PROJECT=true
ENV PATH="$POETRY_HOME/bin:$PATH"

RUN python -m pip install --no-cache-dir poetry

WORKDIR /app

# Copy dependency files first for better caching
COPY pyproject.toml ./

# Install dependencies (no dev dependencies for production)
RUN poetry install --no-interaction --no-ansi --no-root --only main || \
    poetry install --no-interaction --no-ansi --no-root

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
