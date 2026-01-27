# syntax=docker/dockerfile:1
# Example: Java application with Maven
#
# This example shows how to use Maven with distroless Java images.
# Uses multi-stage build: compile with full JDK, run with minimal JRE.
#
# Build:
#   docker build -t myapp .
#
# Run:
#   docker run -p 8080:8080 myapp

# Stage 1: Build with Maven
FROM maven:3.9-eclipse-temurin-21 AS builder

WORKDIR /app

# Copy pom.xml first for better caching
COPY pom.xml ./

# Download dependencies (cached unless pom.xml changes)
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Build the application
RUN mvn package -DskipTests -B

# Stage 2: Production image
FROM ghcr.io/panteparak/distroless/java:21-debian12-nonroot

# Copy JAR from builder
COPY --from=builder /app/target/*.jar /app/app.jar

WORKDIR /app

EXPOSE 8080

# Run the application
ENTRYPOINT ["/usr/bin/java", "-jar", "app.jar"]
