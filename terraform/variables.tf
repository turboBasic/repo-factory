variable "repo_name" {
  type        = string
  description = "Name of the GitHub repository to create"
}

variable "description" {
  type        = string
  description = "Repository description (shown on GitHub)"
  default     = ""
}

variable "visibility" {
  type        = string
  description = "Repository visibility: private or public"
  default     = "private"

  validation {
    condition     = contains(["private", "public"], var.visibility)
    error_message = "visibility must be 'private' or 'public'."
  }
}

variable "create_teams" {
  type        = bool
  description = "Create <repo>-admins and <repo>-contributors teams (requires an organisation owner)"
  default     = false
}

variable "github_token" {
  type        = string
  description = "Short-lived GitHub App installation token (set via TF_VAR_github_token)"
  sensitive   = true
}

variable "github_owner" {
  type        = string
  description = "GitHub account or organisation that owns the repository (set via TF_VAR_github_owner)"
}
