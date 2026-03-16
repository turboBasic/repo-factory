# Root-level Terraform entrypoint for repository provisioning.
#
# Design: this file is intentionally thin — it declares input variables,
# delegates all resource creation to the github_repo module, and surfaces
# the most-used outputs.  Keep resource definitions inside the module so
# they can be tested and reused independently.

module "repo" {
  source = "./modules/github_repo"

  repo_name    = var.repo_name
  description  = var.description
  visibility   = var.visibility
  create_teams = var.create_teams
}
