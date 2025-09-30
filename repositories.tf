# *********************************************************
# REPOSITORIES
# *********************************************************

# ---------------------------------------------------------
# Create Repositories
# ---------------------------------------------------------

resource "github_repository" "repo" {
  for_each = var.repositories

  name         = each.value.name
  description  = each.value.description
  homepage_url = each.value.url
  visibility   = each.value.visibility
  archived     = each.value.archived

  delete_branch_on_merge = true

  has_downloads   = false
  has_issues      = true
  has_discussions = each.value.has_discussions
  has_projects    = each.value.has_projects
  has_wiki        = each.value.has_wiki

  vulnerability_alerts = true

  archive_on_destroy = true
}

# ---------------------------------------------------------
# Attach Repositories To Teams
# ---------------------------------------------------------

resource "github_team_repository" "team-repo" {
  for_each = merge([for tkey, tval in var.teams : { for rkey, rval in var.repositories : "${tkey}-${rkey}" => { team = tkey, repo = rkey, permission = tval.permission } }]...)

  team_id    = github_team.team[each.value.team].id
  repository = github_repository.repo[each.value.repo].name
  permission = each.value.permission
}

# ---------------------------------------------------------
# Branch Protection
# ---------------------------------------------------------

resource "github_branch_protection" "branch-protection" {
  for_each = merge([for rkey, rval in var.repositories : { for pbkey, pbvalue in rval.protected_branches : "${rkey}-${pbkey}" => merge(pbvalue, { repo = rkey }) }]...)

  repository_id = github_repository.repo[each.value.repo].node_id

  pattern                         = each.value.pattern
  enforce_admins                  = true
  required_linear_history         = true
  require_conversation_resolution = true
  require_signed_commits          = true
  allows_deletions                = true
  allows_force_pushes             = false
  lock_branch                     = each.value.read_only

  required_status_checks {
    strict   = true
    contexts = each.value.checks
  }

  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    required_approving_review_count = each.value.required_approving_review_count
    require_code_owner_reviews      = each.value.require_code_owner_reviews
  }
}

# ---------------------------------------------------------
# Environments
# ---------------------------------------------------------

locals {
  environments = merge([for rkey, rval in var.repositories : { for ekey, evalue in rval.environments : "${rkey}-${ekey}" => merge(evalue, { repo = rkey }) }]...)
}

data "github_user" "env-reviewer-user" {
  # Find all users that are not all numbers (e.g assumed to be a username rather than ID) so we can perform a data lookup
  for_each = toset(flatten([for env in local.environments : [for user in env.reviewers.users : user if can(tonumber(user)) == false]]))

  username = each.value
}

data "github_team" "env-reviewer-team" {
  # Find all teams that are not all numbers (e.g assumed to be a team name rather than ID) and also not a key in the teams created in this module so we can perform a data lookup
  for_each = toset(flatten([for env in local.environments : [for team in env.reviewers.teams : team if can(tonumber(team)) == false && can(github_team.team[team]) == false]]))

  slug = each.value
}

resource "github_repository_environment" "environment" {
  for_each = local.environments

  environment         = each.value.name
  repository          = github_repository.repo[each.value.repo].name
  can_admins_bypass   = each.value.can_admins_bypass
  prevent_self_review = each.value.prevent_self_review
  reviewers {
    users = length(each.value.reviewers.users) > 0 ? [for user in each.value.reviewers.users : try(data.github_user.env-reviewer-user[user].id, user)] : null
    teams = length(each.value.reviewers.teams) > 0 ? [for team in each.value.reviewers.teams : try(github_team.team[team].id, try(data.github_team.env-reviewer-team[team].id, team))] : null # Order: team created in this module -> team via data block -> team ID
  }
  deployment_branch_policy {
    protected_branches     = each.value.protected_branches_only
    custom_branch_policies = each.value.custom_branch_policies
  }
}

# ---------------------------------------------------------
# Allowed Actions
# ---------------------------------------------------------

resource "github_actions_repository_permissions" "allowed-actions" {
  for_each = var.repositories

  repository = github_repository.repo[each.key].name

  allowed_actions = var.default_actions_allowed_restricted ? "selected" : "all"
  enabled         = true

  allowed_actions_config {
    github_owned_allowed = true
    verified_allowed     = var.default_actions_verified_allowed
    patterns_allowed     = concat(var.default_actions_allowed_patterns, each.value.allowed_actions)
  }
}

# ---------------------------------------------------------
# Issue Labels
# ---------------------------------------------------------

resource "github_issue_label" "label" {
  for_each = merge([for rkey, rval in var.repositories : { for ilkey, ilvalue in rval.issue_labels : "${rkey}-${ilkey}" => merge(ilvalue, { repo = rkey }) }]...)

  repository  = github_repository.repo[each.value.repo].name
  name        = each.value.name
  color       = each.value.color
  description = each.value.description
}
