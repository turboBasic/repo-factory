output "clone_url" {
  description = "HTTPS clone URL of the new repository"
  value       = module.repo.clone_url
}

output "ssh_url" {
  description = "SSH clone URL of the new repository"
  value       = module.repo.ssh_url
}

output "full_name" {
  description = "Full repository name in org/repo format"
  value       = module.repo.full_name
}
