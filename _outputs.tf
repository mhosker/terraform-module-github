# *********************************************************
# OUTPUTS
# *********************************************************

# ---------------------------------------------------------
# Variables
# ---------------------------------------------------------

output "var_default_actions_allowed_restricted" {
  value = var.default_actions_allowed_restricted
}

output "var_default_actions_verified_allowed" {
  value = var.default_actions_verified_allowed
}

output "var_default_actions_allowed_patterns" {
  value = var.default_actions_allowed_patterns
}

output "var_repositories" {
  value = var.repositories
}

output "var_teams" {
  value = var.teams
}

# ---------------------------------------------------------
# Resources
# ---------------------------------------------------------

output "repositories" {
  value = github_repository.repo
}

output "teams" {
  value = github_team.team
}
