# Terraform and provider version constraints.
#
# GitHub App authentication is used in preference to a personal access token
# because it provides fine-grained, installation-scoped permissions that can
# be revoked per-repository.  The three variables below map to the environment
# variables REPO_AUTOMATION_APP_ID, REPO_AUTOMATION_APP_INSTALLATION_ID, and
# REPO_AUTOMATION_APP_PRIVATE_KEY that are set by the GitHub Actions workflow
# (via TF_VAR_* exports in the orchestration script).

terraform {
  required_version = ">= 1.14"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "github" {
  app_auth {
    id              = var.github_app_id
    installation_id = var.github_app_installation_id
    pem_file        = var.github_app_pem_file
  }
}

variable "github_app_id" {
  type        = string
  description = "GitHub App ID (set via TF_VAR_github_app_id)"
}

variable "github_app_installation_id" {
  type        = string
  description = "GitHub App installation ID (set via TF_VAR_github_app_installation_id)"
}

variable "github_app_pem_file" {
  type        = string
  description = "GitHub App private key PEM content (set via TF_VAR_github_app_pem_file)"
  sensitive   = true
}
