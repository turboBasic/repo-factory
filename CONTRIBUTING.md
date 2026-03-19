# Contributing

## Branching and pull requests

- Contribute using pull requests to `main` from your feature branch. Direct pushes to
  `main` are not allowed (enforced by branch protection Rulesets).
- Feature branches are individually owned and may be force-pushed.

## Merging

- Merge commits are not allowed (enforced by Rulesets). Merge PRs using **Rebase & Squash**
  or **Rebase** if you want your PR to appear as individual commits.

## Commit messages

PRs and individual commits must follow [Conventional Commits] format (enforced by CI).
See [`.github/workflows/conventional-commits.yml`](.github/workflows/conventional-commits.yml)
for the configured commit types and validation rules.

## Linting

[pre-commit] is the linter orchestrator. Currently the following linters are configured:

- **Python** — [Ruff] (format + lint), [mypy] (type checking)
- **YAML** — [yamllint]
- **Shell** — [shellcheck]
- **Markdown** — [pymarkdown]
- **JavaScript / JSON** — [Biome]

To add a new linter, add a hook entry in [`.pre-commit-config.yaml`](.pre-commit-config.yaml).

<!-- Links -->
[Biome]: https://github.com/biomejs/biome
[mypy]: https://github.com/python/mypy
[Conventional Commits]: https://www.conventionalcommits.org
[pre-commit]: https://github.com/pre-commit/pre-commit
[pymarkdown]: https://github.com/jackdewinter/pymarkdown
[Ruff]: https://github.com/astral-sh/ruff
[shellcheck]: https://github.com/koalaman/shellcheck
[yamllint]: https://github.com/adrienverge/yamllint
