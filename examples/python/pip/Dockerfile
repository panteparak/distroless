# syntax=docker/dockerfile:1
# Example: Python application with traditional pip
#
# This is the traditional approach using pip and requirements.txt.
# For new projects, consider using UV or Poetry instead.
#
# Build:
#   docker build -t myapp .
#
# Run:
#   docker run -p 8080:8080 myapp

# Stage 1: Build with pip
FROM python:3.13-slim AS builder

WORKDIR /app

# Create virtual environment
RUN python -m venv /app/.venv

# Copy requirements first for better caching
COPY requirements.txt ./

# Install dependencies
RUN . /app/.venv/bin/activate && \
    pip install --no-cache-dir -r requirements.txt

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
