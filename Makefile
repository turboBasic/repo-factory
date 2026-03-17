.DEFAULT_GOAL := help

TERRAFORM_DIR := terraform
TESTS_DIR     := tests

# ── Help ──────────────────────────────────────────────────────────────────────

.PHONY: help
help: ## Show available make targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

# ── Terraform ─────────────────────────────────────────────────────────────────

.PHONY: tf-init
tf-init: ## Initialise Terraform providers
	terraform -chdir=$(TERRAFORM_DIR) init

.PHONY: tf-fmt
tf-fmt: ## Format all Terraform files in-place
	terraform -chdir=$(TERRAFORM_DIR) fmt -recursive

.PHONY: tf-validate
tf-validate: tf-init ## Validate Terraform configuration (no credentials needed)
	terraform -chdir=$(TERRAFORM_DIR) validate

.PHONY: tf-plan
tf-plan: tf-init ## Show Terraform plan (requires TF_VAR_* env vars)
	terraform -chdir=$(TERRAFORM_DIR) plan

# ── Testing ───────────────────────────────────────────────────────────────────

.PHONY: test
test: ## Run template integration tests
	pytest $(TESTS_DIR) -v

# ── Linting ───────────────────────────────────────────────────────────────────

.PHONY: lint-tf
lint-tf: tf-fmt tf-validate ## Lint Terraform: format + validate

.PHONY: lint-py
lint-py: ## Lint Python test files
	ruff check $(TESTS_DIR)

.PHONY: lint
lint: lint-tf lint-py ## Run all linters

# ── Install ───────────────────────────────────────────────────────────────────

.PHONY: install
install: ## Install Python dev dependencies (copier, pytest)
	pip install -e ".[dev]"
