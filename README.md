# repo-factory

Create and scaffold GitHub repositories.

## Overview

This repository contains infrastructure and automation for bootstrapping repository
configuration using project templates.

## Technology stack

- Terraform
- [Copier]
- GitHub Actions

## Repository layout

See [Project Structure][project-structure]

## Prerequisites

These prerequisites describe what you need for local development (running template
tests, rendering templates, or creating repositories from templates on your machine).
Continuous Integration (GitHub Actions) and the repository workflows install the
necessary tools when they run in CI; install the items below locally only if you
intend to run the commands or tests on your workstation.

- [mise] — manages Python, Terraform, and uv versions per `.mise.toml`
  (recommended for a reproducible local toolchain).
- Python 3.14 and [uv] (both managed by `mise`) — required to run the
  project's tests and local template tooling. uv manages the virtual
  environment and installs dev dependencies.
- [pre-commit] — runs configured pre-commit hooks that execute linters and
  formatters locally. Install with `uv tool install pre-commit` or via
  `make install`, then enable hooks with `pre-commit install`.
- [Copier] — used to render templates and run template integration tests
  locally. Install with `uv tool install copier` or via `make install`. Note:
  GitHub Actions workflows install `copier` in CI, so if you only use the
  hosted "Create Repository" workflow you do not need to install `copier`
  locally.
- Terraform for local testing and executing Terraform code.
- A GitHub App with the required permissions (see
  [GitHub App setup](#github-app-setup)) — required when running the
  creation scripts locally or when automation uses the App credentials.

## Quick start

```bash
# 1. Install toolchain (Python, Terraform, uv)
mise install

# 2. Install Python dev dependencies (copier, pytest) into the uv-managed venv
make install

# 3. Run template tests
make test

# 4. Create a new repository (requires env vars set below)
scripts/create_repo.sh python-app my-new-service "A new service"
```

## GitHub App setup

Create a GitHub App with the following permissions:

| Permission | Access | Required when |
| --- | --- | --- |
| Repository: Actions | Read | Always |
| Repository: Administration | Read and write | Always |
| Repository: Contents | Read and write | Always |
| Repository: Issues | Read and write | Optional |
| Repository: Metadata | Read | Always |
| Repository: Pull requests | Read and write | Optional |
| Repository: Workflows | Read and write | Always |
| Organization: Administration | Read and write | `create_teams = true` (org owners only) |
| Organization: Members | Read and write | `create_teams = true` (org owners only) |

Install the App on your account or organisation and note the **App ID**.
Store the following as GitHub Actions secrets:

| Secret | Description |
| --- | --- |
| `REPO_AUTOMATION_APP_ID` | GitHub App ID |
| `REPO_AUTOMATION_APP_PRIVATE_KEY` | Private key PEM (full content) |
| `REPO_AUTOMATION_PAT` | Fine-grained PAT used for personal-account repository creation (`POST /user/repos`) |

The workflow exchanges these for a short-lived installation token via
`actions/create-github-app-token` before running Terraform and git push.
The installation ID is discovered automatically — you do not need to store it.
When `github_org` is empty, the workflow creates the repository under the
workflow repository owner account and requires `REPO_AUTOMATION_PAT`.
When `github_org` is set, the workflow creates the repository in that
organisation and uses a short-lived GitHub App installation token.

## Creating a repository via GitHub Actions

Go to **Actions → Create Repository → Run workflow** and fill in:

- **template** — `python-app`
- **repo_name** — name for the new repository (e.g. `payments-api`)
- **description** — optional one-line description
- **github_org** — leave empty for personal-account owner, or set an
  organisation login to create the repository in that organisation
- **create_teams** — set to `true` to create `<repo>-admins` and `<repo>-contributors`
  teams (requires an organisation owner and the Organization: Members permission)

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
[pre-commit]: https://pre-commit.com/
[project-structure]: docs/ai-instructions.md#project-structure
[uv]: https://docs.astral.sh/uv/
