# GitHub repository module.
#
# Responsibility: infrastructure only.
# This module creates the remote repository and configures its default branch.
# It does NOT commit any files — the orchestration script handles that after
# Copier has rendered the project skeleton.
#
# auto_init = false is intentional: we push an initial commit ourselves so
# that the history matches the Copier-generated content exactly.

terraform {
  required_providers {
    github = {
      source = "integrations/github"
    }
  }
}

resource "github_repository" "repo" {
  name        = var.repo_name
  description = var.description
  visibility  = var.visibility

  # Do not auto-initialise — the orchestration script pushes the first commit.
  auto_init = false

  has_issues   = true
  has_wiki     = false
  has_projects = false

  # Prevent accidental deletion via Terraform.
  lifecycle {
    prevent_destroy = true
  }
}

# Teams scoped to this repository (org owners only; skipped for personal accounts).
resource "github_team" "admins" {
  count       = var.create_teams ? 1 : 0
  name        = "${var.repo_name}-admins"
  description = "Admins for ${var.repo_name}"
  privacy     = "closed"
}

resource "github_team" "contributors" {
  count       = var.create_teams ? 1 : 0
  name        = "${var.repo_name}-contributors"
  description = "Contributors for ${var.repo_name}"
  privacy     = "closed"
}

resource "github_team_repository" "admins" {
  count      = var.create_teams ? 1 : 0
  team_id    = github_team.admins[0].id
  repository = github_repository.repo.name
  permission = "admin"
}

resource "github_team_repository" "contributors" {
  count      = var.create_teams ? 1 : 0
  team_id    = github_team.contributors[0].id
  repository = github_repository.repo.name
  permission = "push"
}

# Set the default branch after the repository exists.
# The branch itself is created by the initial git push in create_repo.sh.
resource "github_branch_default" "default" {
  repository = github_repository.repo.name
  branch     = "main"

  # Wait until after the push creates the branch; use depends_on to force
  # ordering when the repo and branch default are applied together.
  depends_on = [github_repository.repo]
}
