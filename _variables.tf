# *********************************************************
# VARIABLES
# *********************************************************

# ---------------------------------------------------------
# Defaults
# ---------------------------------------------------------

variable "default_actions_allowed_restricted" {
  type        = bool
  description = "Whether GitHub actions should be restricted in repos."
  default     = true
}

variable "default_actions_verified_allowed" {
  type        = bool
  description = "Whether actions in GitHub Marketplace from verified creators are allowed."
  default     = false
}

variable "default_actions_allowed_patterns" {
  type        = list(string)
  description = "Default GitHub Actions Allowed Patterns"
  default     = ["aws-actions/*", "azure/*", "hashicorp/*"]
}

# ---------------------------------------------------------
# Repositories
# ---------------------------------------------------------

variable "repositories" {
  type = map(object({
    name            = string
    description     = string
    url             = optional(string, null)
    has_projects    = optional(bool, false)
    has_discussions = optional(bool, false)
    has_wiki        = optional(bool, false)
    visibility      = optional(string, "internal")
    archived        = optional(bool, false)
    allowed_actions = optional(list(string), [])
    protected_branches = optional(map(object({
      pattern                         = string
      checks                          = optional(list(string), [])
      required_approving_review_count = optional(number, 0)
      require_code_owner_reviews      = optional(bool, false)
      read_only                       = optional(bool, false)
    })), {})
    environments = optional(map(object({
      name                    = string
      can_admins_bypass       = optional(bool, false)
      prevent_self_review     = optional(bool, false)
      protected_branches_only = optional(bool, true)
      custom_branch_policies  = optional(bool, false)
      reviewers = optional(object({
        users = optional(list(string), []) # Either ID (number) OR GitHub username
        teams = optional(list(string), []) # Either ID (number) OR key from team map OR GitHub team name
      }), {})
    })), {})
    issue_labels = optional(map(object({
      name        = string
      color       = string
      description = optional(string, "")
    })), {})
  }))
  description = "Repositories to create."
}

# ---------------------------------------------------------
# Teams
# ---------------------------------------------------------

variable "teams" {
  type = map(object({
    name        = string
    description = string
    permission  = string
    privacy     = optional(string, "closed")
    members = map(object({
      role = optional(string, "member")
    }))
  }))
  description = "Teams to create."
}
