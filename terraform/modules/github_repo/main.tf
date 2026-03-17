# GitHub repository module.
#
# Responsibility: infrastructure only.
# This module creates the remote repository and configures its default branch.
# It does NOT commit any files — the orchestration script handles that after
# Copier has rendered the project skeleton.
#
# auto_init = false is intentional: we push an initial commit ourselves so
# that the history matches the Copier-generated content exactly.

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

# Set the default branch after the repository exists.
# The branch itself is created by the initial git push in create_repo.sh.
resource "github_branch_default" "default" {
  repository = github_repository.repo.name
  branch     = "main"

  # Wait until after the push creates the branch; use depends_on to force
  # ordering when the repo and branch default are applied together.
  depends_on = [github_repository.repo]
}
