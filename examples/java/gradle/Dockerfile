# syntax=docker/dockerfile:1
# Example: Java application with Gradle
#
# This example shows how to use Gradle with distroless Java images.
# Uses multi-stage build: compile with full JDK, run with minimal JRE.
#
# Build:
#   docker build -t myapp .
#
# Run:
#   docker run -p 8080:8080 myapp

# Stage 1: Build with Gradle
FROM gradle:8-jdk21 AS builder

WORKDIR /app

# Copy build files first for better caching
COPY build.gradle settings.gradle ./

# Download dependencies (cached unless build files change)
RUN gradle dependencies --no-daemon || true

# Copy source code
COPY src ./src

# Build the application
RUN gradle jar --no-daemon

# Stage 2: Production image
FROM ghcr.io/panteparak/distroless/java:21-debian12-nonroot

# Copy JAR from builder
COPY --from=builder /app/build/libs/*.jar /app/app.jar

WORKDIR /app

EXPOSE 8080

# Run the application
ENTRYPOINT ["/usr/bin/java", "-jar", "app.jar"]
