# Distroless Image Build System
# =============================

REGISTRY ?= ghcr.io
IMAGE_PREFIX ?= panteparak/distroless
DEBIAN_VERSION ?= debian12
PLATFORMS ?= linux/amd64,linux/arm64

# Image versions
PYTHON_VERSIONS := 3.8 3.9 3.10 3.11 3.12 3.13
NODEJS_VERSIONS := 20 22 24
JAVA_VERSIONS := 17 21

# User variants
USERS := root nonroot

.PHONY: all clean lint test build push help

# =============================================================================
# Help
# =============================================================================

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# =============================================================================
# Main targets
# =============================================================================

all: lint build test ## Run lint, build, and test

clean: ## Clean up build artifacts
	docker system prune -f
	rm -rf build/

lint: ## Lint Dockerfiles and scripts
	@echo "=== Linting Dockerfiles ==="
	@find images -name "Dockerfile*" -exec hadolint {} \;
	@echo "=== Linting shell scripts ==="
	@find . -name "*.sh" -exec shellcheck {} \;

test: ## Run container structure tests
	@echo "=== Running structure tests ==="
	@for image in static base cc; do \
		echo "Testing $$image..."; \
		container-structure-test test \
			--image $(REGISTRY)/$(IMAGE_PREFIX)/$$image:$(DEBIAN_VERSION) \
			--config tests/structure-tests/$$image.yaml || true; \
	done

test-python: ## Run Python structure tests
	@echo "=== Running Python structure tests ==="
	@for version in $(PYTHON_VERSIONS); do \
		echo "Testing python:$$version..."; \
		container-structure-test test \
			--image $(REGISTRY)/$(IMAGE_PREFIX)/python:$$version-$(DEBIAN_VERSION) \
			--config tests/structure-tests/python.yaml || true; \
	done

test-nodejs: ## Run Node.js structure tests
	@echo "=== Running Node.js structure tests ==="
	@for version in $(NODEJS_VERSIONS); do \
		echo "Testing nodejs:$$version..."; \
		container-structure-test test \
			--image $(REGISTRY)/$(IMAGE_PREFIX)/nodejs:$$version-$(DEBIAN_VERSION) \
			--config tests/structure-tests/nodejs.yaml || true; \
	done


# =============================================================================
# Build targets
# =============================================================================

build: build-static build-base build-cc ## Build all base images

build-static: ## Build static image
	@echo "=== Building static image ==="
	@for user in $(USERS); do \
		uid=0; workdir="/"; \
		if [ "$$user" = "nonroot" ]; then uid=65532; workdir="/home/nonroot"; fi; \
		echo "Building static:$(DEBIAN_VERSION)-$$user"; \
		docker buildx build \
			--platform $(PLATFORMS) \
			--build-arg USER=$$user \
			--build-arg UID=$$uid \
			--build-arg WORKDIR=$$workdir \
			-t $(REGISTRY)/$(IMAGE_PREFIX)/static:$(DEBIAN_VERSION)-$$user \
			-f images/static/Dockerfile \
			images/static \
			--load; \
	done

build-base: build-static ## Build base image (depends on static)
	@echo "=== Building base image ==="
	@for user in $(USERS); do \
		uid=0; workdir="/"; \
		if [ "$$user" = "nonroot" ]; then uid=65532; workdir="/home/nonroot"; fi; \
		echo "Building base:$(DEBIAN_VERSION)-$$user"; \
		docker buildx build \
			--platform $(PLATFORMS) \
			--build-arg STATIC_IMAGE=$(REGISTRY)/$(IMAGE_PREFIX)/static \
			--build-arg TAG=$(DEBIAN_VERSION)-$$user \
			--build-arg USER=$$user \
			--build-arg UID=$$uid \
			-t $(REGISTRY)/$(IMAGE_PREFIX)/base:$(DEBIAN_VERSION)-$$user \
			-f images/base/Dockerfile \
			images/base \
			--load; \
	done

build-cc: build-base ## Build cc image (depends on base)
	@echo "=== Building cc image ==="
	@for user in $(USERS); do \
		uid=0; workdir="/"; \
		if [ "$$user" = "nonroot" ]; then uid=65532; workdir="/home/nonroot"; fi; \
		echo "Building cc:$(DEBIAN_VERSION)-$$user"; \
		docker buildx build \
			--platform $(PLATFORMS) \
			--build-arg BASE_IMAGE=$(REGISTRY)/$(IMAGE_PREFIX)/base \
			--build-arg TAG=$(DEBIAN_VERSION)-$$user \
			--build-arg USER=$$user \
			--build-arg UID=$$uid \
			-t $(REGISTRY)/$(IMAGE_PREFIX)/cc:$(DEBIAN_VERSION)-$$user \
			-f images/cc/Dockerfile \
			images/cc \
			--load; \
	done

build-python: build-cc ## Build Python images
	@echo "=== Building Python images ==="
	@for version in $(PYTHON_VERSIONS); do \
		for user in $(USERS); do \
			echo "Building python:$$version-$$user"; \
			docker buildx build \
				--platform $(PLATFORMS) \
				--build-arg PYTHON_VERSION=$$version \
				--build-arg USER=$$user \
				-t $(REGISTRY)/$(IMAGE_PREFIX)/python:$$version-$$user \
				-f images/python/Dockerfile.$$version \
				images/python \
				--load; \
		done; \
	done

build-nodejs: build-cc ## Build Node.js images
	@echo "=== Building Node.js images ==="
	@for version in $(NODEJS_VERSIONS); do \
		for user in $(USERS); do \
			echo "Building nodejs:$$version-$$user"; \
			docker buildx build \
				--platform $(PLATFORMS) \
				--build-arg NODE_VERSION=$$version \
				--build-arg USER=$$user \
				-t $(REGISTRY)/$(IMAGE_PREFIX)/nodejs:$$version-$(DEBIAN_VERSION)-$$user \
				-f images/nodejs/Dockerfile.$$version \
				images/nodejs \
				--load; \
		done; \
	done

build-java: build-base ## Build Java images
	@echo "=== Building Java images ==="
	@for version in $(JAVA_VERSIONS); do \
		for user in $(USERS); do \
			echo "Building java:$$version-$$user"; \
			docker buildx build \
				--platform $(PLATFORMS) \
				--build-arg JAVA_VERSION=$$version \
				--build-arg USER=$$user \
				-t $(REGISTRY)/$(IMAGE_PREFIX)/java:$$version-$$user \
				-f images/java/Dockerfile.$$version \
				images/java \
				--load; \
		done; \
	done

# =============================================================================
# Debug image targets
# =============================================================================

build-debug: build ## Build all debug variants
	@echo "=== Building debug images ==="
	@for image in static base cc; do \
		for user in $(USERS); do \
			suffix=""; \
			if [ "$$user" = "nonroot" ]; then suffix="-nonroot"; fi; \
			echo "Building $$image:$(DEBIAN_VERSION)-debug$$suffix"; \
			docker buildx build \
				--platform $(PLATFORMS) \
				--build-arg BASE_IMAGE=$(REGISTRY)/$(IMAGE_PREFIX)/$$image \
				--build-arg TAG=$(DEBIAN_VERSION)-$$user \
				-t $(REGISTRY)/$(IMAGE_PREFIX)/$$image:$(DEBIAN_VERSION)-debug$$suffix \
				-f images/$$image/Dockerfile.debug \
				images/$$image \
				--load; \
		done; \
	done

# =============================================================================
# Push targets
# =============================================================================

push: ## Push all images to registry
	@echo "=== Pushing images ==="
	docker push $(REGISTRY)/$(IMAGE_PREFIX)/static --all-tags
	docker push $(REGISTRY)/$(IMAGE_PREFIX)/base --all-tags
	docker push $(REGISTRY)/$(IMAGE_PREFIX)/cc --all-tags

# =============================================================================
# Development helpers
# =============================================================================

dev-static: ## Build static image for local development (amd64 only)
	docker build \
		--build-arg USER=root \
		--build-arg UID=0 \
		--build-arg WORKDIR=/ \
		-t distroless-static:dev \
		-f images/static/Dockerfile \
		images/static

shell-debug: dev-static ## Run debug shell in static image
	docker build \
		--build-arg BASE_IMAGE=distroless-static \
		--build-arg TAG=dev \
		-t distroless-static:debug \
		-f images/static/Dockerfile.debug \
		images/static
	docker run -it --rm distroless-static:debug

pre-commit: ## Run pre-commit hooks
	pre-commit run --all-files

install-hooks: ## Install pre-commit hooks
	pre-commit install
