variable "repo_name" {
  type        = string
  description = "Repository name (must be unique within the organisation)"
}

variable "description" {
  type        = string
  description = "Short description shown on the GitHub repository page"
  default     = ""
}

variable "visibility" {
  type        = string
  description = "Repository visibility: private or public"
  default     = "private"
}

variable "create_teams" {
  type        = bool
  description = "Create <repo>-admins and <repo>-contributors teams (requires an organisation owner)"
  default     = false
}
