# AI Instructions

> **Single source of truth for AI coding instructions.**
>
> - **Claude Code** reads this via `CLAUDE.md` (`@docs/ai-instructions.md`).
> - **GitHub Copilot** reads `.github/copilot-instructions.md`, which links to this file.
> - **Edit only this file.** CI verifies Copilot instructions reference it.

---

## Project Overview

**repo-factory**: Create and scaffold GitHub repository

## Tech Stack

| Tool | Version / Notes |
| --- | --- |
| Primary language | Terraform (HCL) |
| Templating | Copier (Jinja2) |
| Test framework | pytest (Python) |
| CI | GitHub Actions |

## Project Structure

> **Keep this section current.** When adding a new directory, update the tree below in the
> same change. Remove entries for deleted directories at the same time.

```plaintext
.claude/
├── settings.json
└── skills/                              # Shared AI skills
.github/
├── workflows/
│   ├── conventional-commits.yml         # PR title / commit message validation
│   └── create-repo.yml                  # Manually triggered repo-factory workflow
└── PULL_REQUEST_TEMPLATE.md
scripts/
└── create_repo.sh                       # Orchestrates Copier → Terraform → git push
templates/
└── python-app/                          # Copier template: Python src-layout project
    ├── copier.yaml
    ├── pyproject.toml.jinja
    ├── README.md.jinja
    ├── src/{{ project_slug }}/
    │   ├── __init__.py.jinja
    │   ├── __main__.py.jinja
    │   └── main.py.jinja
    ├── tests/
    │   └── test_import.py.jinja
    └── .github/workflows/
        └── ci.yml.jinja
terraform/
├── modules/
│   └── github_repo/                     # Reusable module: creates one GitHub repo
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── providers.tf                         # Terraform + GitHub provider (App auth)
└── repo.tf                              # Root entrypoint: variables + module call
tests/
└── test_template.py                     # Integration tests for Copier templates
docs/
└── ai-instructions.md                   # ← you are here
pyproject.toml                           # Python dev/test dependencies (copier, pytest)
Makefile                                 # Developer shortcuts
CONTRIBUTING.md                          # Branching, merging, commit, and linting conventions
README.md                                # Instructions for developers
```

## Code Style & Conventions

### Formatting (Source of Truth)

- Follow `.editorconfig` in the repository root for formatting rules.
- This includes charset, line endings, indentation, trailing whitespace, final newline,
  and file-type-specific overrides.
- If a formatting rule here ever conflicts with `.editorconfig`, `.editorconfig` wins.
- When generating or formatting code, consult the linter configuration files:
  - **Python** — `pyproject.toml` (`[tool.ruff]` and `[tool.ruff.lint]` sections)
  - **JavaScript / TypeScript / JSON** — `.biome.json`
  - **YAML** — `.yamllint`
  - **Markdown** — `.pymarkdown`

### Adding a new file type

When introducing a file type that is not yet covered, update **both** config files:

1. **`.editorconfig`** — add a glob section with the appropriate overrides.
2. **`.gitattributes`** — add an entry with `text eol=lf` (or `eol=crlf` for Windows-only
   files, or `binary` for binary assets). Add `diff=<language>` when git has a built-in
   driver for that language.

Do this as part of the same change that adds the first file of that type.

### Python

- Use type hints for new functions
- Keep scripts short and focused; prefer stdlib over adding dependencies

### YAML (GitHub Actions)

- Pin action versions to a major tag (e.g., `actions/checkout@v4`)
- Always set `timeout-minutes` on jobs

## Workflow & Tooling

### Installing dependencies

```bash
# Install Python + Terraform versions defined in .mise.toml
mise install

# Install Python dev/test dependencies (copier, pytest)
make install   # equivalent to: pip install -e ".[dev]"
```

### Developer commands (Makefile)

```bash
make help        # list all targets with descriptions
make test        # run template integration tests with pytest
make lint        # format + validate Terraform; ruff-check Python tests
make tf-init     # initialise Terraform providers
make tf-fmt      # format all .tf files in-place
make tf-validate # validate Terraform config (no credentials needed)
make tf-plan     # preview changes (requires TF_VAR_* environment variables)
```

### Adding dependencies

- **Python test/dev**: add to `[project.optional-dependencies] dev` in `pyproject.toml`.
- **Terraform providers**: add to `required_providers` in `terraform/providers.tf` and
  run `make tf-init` to update the lock file.
- **Copier template Python deps**: add to `[project.optional-dependencies] dev` in
  `templates/python-app/pyproject.toml.jinja`.

## AI Behavior Guidelines

- **Minimal changes**: prefer targeted edits over large refactors unless explicitly asked
- **Follow existing patterns**: read the surrounding code before suggesting changes
- **Formatting and linting**: after making changes, run the relevant formatter and linter commands for the affected files when practical (for example `make fmt` and `make lint`) and fix issues introduced by the change before finishing; if unrelated pre-existing issues remain, call them out clearly
- **No secrets**: never generate tokens, passwords, or credentials — use GitHub Actions secrets
- **Skills source of truth**: keep shared skills only in `.claude/skills/`; GitHub Copilot must use these shared skills and must not duplicate skill definitions under `.github/skills/`
- **Commit messages**: use Conventional Commits format `type(scope): subject`
  (e.g. `fix(ci): handle missing env variable`), with an imperative subject and no trailing
  period
