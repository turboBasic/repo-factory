output "clone_url" {
  description = "HTTPS clone URL"
  value       = github_repository.repo.http_clone_url
}

output "ssh_url" {
  description = "SSH clone URL"
  value       = github_repository.repo.ssh_clone_url
}

output "full_name" {
  description = "Full repository name (organisation/repository)"
  value       = github_repository.repo.full_name
}

output "node_id" {
  description = "GraphQL node ID of the repository"
  value       = github_repository.repo.node_id
}

output "admins_team_slug" {
  description = "Slug of the <repo>-admins team, or null when create_teams is false"
  value       = var.create_teams ? github_team.admins[0].slug : null
}

output "contributors_team_slug" {
  description = "Slug of the <repo>-contributors team, or null when create_teams is false"
  value       = var.create_teams ? github_team.contributors[0].slug : null
}
