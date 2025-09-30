# *********************************************************
# TEAMS
# *********************************************************

# ---------------------------------------------------------
# Create Teams
# ---------------------------------------------------------

resource "github_team" "team" {
  for_each = var.teams

  name        = each.value.name
  description = each.value.description
  privacy     = each.value.privacy
}

# ---------------------------------------------------------
# Add Team Members
# ---------------------------------------------------------

resource "github_team_members" "team-members" {
  for_each = { for k, v in var.teams : k => v if length(v.members) > 0 }

  team_id = github_team.team[each.key].id

  dynamic "members" {
    for_each = each.value.members
    content {
      username = members.key
      role     = members.value.role
    }
  }
}