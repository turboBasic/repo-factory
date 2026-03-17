#!/usr/bin/env bash
# create_repo.sh — orchestrate Copier → Terraform → git push.
#
# Usage:
#   scripts/create_repo.sh <template> <repo-name> [description]
#
# Example:
#   scripts/create_repo.sh python-app payments-api "Payments microservice"
#
# Required environment variables (GitHub App credentials):
#   REPO_AUTOMATION_APP_ID
#   REPO_AUTOMATION_APP_INSTALLATION_ID
#   REPO_AUTOMATION_APP_PRIVATE_KEY
#
# The script maps those variables to TF_VAR_* names that Terraform expects,
# so the provider block never reads credentials from files.

set -euo pipefail

# ── Argument parsing ──────────────────────────────────────────────────────────

TEMPLATE="${1:?ERROR: template name required. Usage: $0 <template> <repo-name> [description]}"
REPO_NAME="${2:?ERROR: repo name required. Usage: $0 <template> <repo-name> [description]}"
DESCRIPTION="${3:-}"

# ── Path resolution ───────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

TEMPLATE_PATH="${REPO_ROOT}/templates/${TEMPLATE}"
TERRAFORM_DIR="${REPO_ROOT}/terraform"
TMP_DIR="${REPO_ROOT}/tmp/${REPO_NAME}"

# ── Pre-flight checks ─────────────────────────────────────────────────────────

if [[ ! -d "${TEMPLATE_PATH}" ]]; then
    echo "ERROR: template '${TEMPLATE}' not found at ${TEMPLATE_PATH}" >&2
    echo "Available templates:" >&2
    ls "${REPO_ROOT}/templates/" >&2
    exit 1
fi

for cmd in copier terraform git; do
    if ! command -v "${cmd}" &>/dev/null; then
        echo "ERROR: '${cmd}' not found on PATH" >&2
        exit 1
    fi
done

# Validate required credentials are present before doing any work.
: "${REPO_AUTOMATION_APP_ID:?REPO_AUTOMATION_APP_ID must be set}"
: "${REPO_AUTOMATION_APP_INSTALLATION_ID:?REPO_AUTOMATION_APP_INSTALLATION_ID must be set}"
: "${REPO_AUTOMATION_APP_PRIVATE_KEY:?REPO_AUTOMATION_APP_PRIVATE_KEY must be set}"

# ── Step 1: Render Copier template ────────────────────────────────────────────

echo "==> [1/3] Rendering template '${TEMPLATE}' into ${TMP_DIR}"

# Remove any previous attempt so Copier always starts clean.
rm -rf "${TMP_DIR}"

# Derive a Python-safe package slug from the repo name (hyphens → underscores).
PROJECT_SLUG="${REPO_NAME//-/_}"

copier copy \
    --defaults \
    --overwrite \
    --data "project_name=${REPO_NAME}" \
    --data "project_slug=${PROJECT_SLUG}" \
    --data "description=${DESCRIPTION}" \
    "${TEMPLATE_PATH}" \
    "${TMP_DIR}"

# ── Step 2: Provision GitHub repository via Terraform ────────────────────────

echo "==> [2/3] Provisioning GitHub repository '${REPO_NAME}'"

# Map the canonical env var names to Terraform's TF_VAR_* convention.
export TF_VAR_github_app_id="${REPO_AUTOMATION_APP_ID}"
export TF_VAR_github_app_installation_id="${REPO_AUTOMATION_APP_INSTALLATION_ID}"
export TF_VAR_github_app_private_key="${REPO_AUTOMATION_APP_PRIVATE_KEY}"
export TF_VAR_repo_name="${REPO_NAME}"
export TF_VAR_description="${DESCRIPTION}"

terraform -chdir="${TERRAFORM_DIR}" init -input=false -upgrade
terraform -chdir="${TERRAFORM_DIR}" apply -input=false -auto-approve

CLONE_URL="$(terraform -chdir="${TERRAFORM_DIR}" output -raw clone_url)"

# ── Step 3: Push generated project to the new repository ─────────────────────

echo "==> [3/3] Pushing initial commit to ${CLONE_URL}"

cd "${TMP_DIR}"

git init
git checkout -b main
git commit --allow-empty -m "chore: root commit"

git add .
git commit -m "chore: initial project scaffold from repo-factory/${TEMPLATE}"

git remote add origin "${CLONE_URL}"
git push --set-upstream origin main

echo ""
echo "Done!  New repository: ${CLONE_URL}"
