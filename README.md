# repo-factory

Create and scaffold GitHub repositories.

## Overview

This repository contains infrastructure and automation for bootstrapping repository
configuration and standards.

## Tech

- Terraform
- [Copier]
- GitHub Actions

## Repository layout

See [Project Structure][project-structure]

## Prerequisites

- [mise] — manages Python and Terraform (see `.mise.toml`)
- Copier — installed via `pip install copier` or `make install`
- A **GitHub App** with *repository create* and *contents write* permissions
  (see [GitHub App setup](#github-app-setup) below)

## Quick start

```bash
# 1. Install toolchain (Python 3.14, Terraform 1.14)
mise install

# 2. Install Python dev dependencies (copier, pytest)
make install

# 3. Run template tests
make test

# 4. Create a new repository (requires env vars set below)
scripts/create_repo.sh python-app my-new-service "A new service"
```

## GitHub App setup

Create a GitHub App with the following permissions:

| Permission | Access |
| --- | --- |
| Repository: Administration | Read and write |
| Repository: Contents | Read and write |

Install the App on your organisation and note the **App ID** and
**Installation ID**.  Export the following variables (or store them as
GitHub Actions secrets):

| Variable | Description |
| --- | --- |
| `REPO_AUTOMATION_APP_ID` | GitHub App ID |
| `REPO_AUTOMATION_APP_INSTALLATION_ID` | Installation ID |
| `REPO_AUTOMATION_APP_PRIVATE_KEY` | Private key PEM (full content) |

## Creating a repository via GitHub Actions

Go to **Actions → Create Repository → Run workflow** and fill in:

- **template** — `python-app`
- **repo_name** — name for the new repository (e.g. `payments-api`)
- **description** — optional one-line description

## Developer commands

```bash
make help        # list all targets
make test        # run template integration tests
make lint        # format + validate Terraform and lint Python
make tf-plan     # preview Terraform changes (requires TF_VAR_* vars)
```

## Getting started (contributing)

1. Clone the repository.
2. Review contribution rules in [CONTRIBUTING.md][contributing].
3. Install and run pre-commit hooks before opening a pull request.

```bash
pre-commit install
pre-commit run --all-files
```

## Contributing

See [CONTRIBUTING.md][contributing] for branching, commit, and linting
conventions.

<!-- Links -->

[contributing]: CONTRIBUTING.md
[Copier]: https://copier.readthedocs.io/en/stable/
[mise]: https://mise.jdx.dev/
[project-structure]: docs/ai-instructions.md#project-structure
