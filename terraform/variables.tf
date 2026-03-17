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
