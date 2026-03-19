.DEFAULT_GOAL := help

TESTS_DIR     := tests

# ── Help ──────────────────────────────────────────────────────────────────────

.PHONY: help
help: ## Show available make targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

# ── Testing ───────────────────────────────────────────────────────────────────

.PHONY: test
test: ## Run template integration tests
	uv run pytest $(TESTS_DIR) -v

# ── Linting ───────────────────────────────────────────────────────────────────

.PHONY: lint-py
lint-py: ## Lint Python files
	uv run ruff check .

.PHONY: lint
lint: lint-py ## Run all linters

# ── Install ───────────────────────────────────────────────────────────────────

.PHONY: install
install: ## Install Python dev dependencies via uv
	uv sync
