# Terraform Module - GitHub
This Terraform module allows you to manage your GitHub configuration in code.

It supports the creation of:
- Repositories
- Branch protection rules
- Actions permissions
- Teams
- Teams permissions
- Environments
- Issue Labels

By using this module you ensure that:
- All repos are built to a standard pattern
- Repos are always delegated to teams
- Branch protection rules are configured in a standardised way
- GitHub actions permissions are configured to a baseline

## Example Usage

The module can be called from your Terraform as shown in this example below:

```hcl
module "example" {
  source = "github.com/mhosker/terraform-module-github?ref=v1.0.0"

  # ---------------------------------------------------------
  # Defaults
  # ---------------------------------------------------------

  # Overriding the default to allow verified GitHub actions in repos
  default_actions_verified_allowed = true

  # Adding custom google-github-actions/* alongside standard defaults (this variable is optional)
  default_actions_allowed_patterns = ["aws-actions/*", "azure/*", "hashicorp/*", "google-github-actions/*"]

  # ---------------------------------------------------------
  # Repositories
  # ---------------------------------------------------------

  repositories = {
    "github" = {
      name               = "github"
      description        = "Terraform management of my GitHub config."
      protected_branches = {
        "main" = {
          pattern = "main"
          checks  = ["Terraform"]
        }
      }
    }
    "terraform-module-github" = {
      name        = "terraform-module-github"
      description = "Module for managing GitHub config in code."
      visibility  = "public"
      protected_branches = {
        "main" = {
          pattern = "main"
        }
      }
    }
    "11ty-blog" = {
      name            = "11ty-blog"
      description     = "11ty powered mikehosker.net blog."
      url             = "https://mikehosker.net"
      has_projects    = true
      allowed_actions = ["cypress-io/*"]
      protected_branches = {
        "main" = {
          pattern   = "main"
          read_only = true
        }
      }
      environments = {
        blue = {
          name = "blue"
          reviewers = {
            teams = ["Admin"]
          }
        }
        green = {
          name = "green"
          reviewers = {
            teams = ["Admin"]
          }
        }
      }
      issue_labels = {
        "Content" = {
          name  = "Content"
          color = "FF0000"
        }
      }
    }
  }

  # ---------------------------------------------------------
  # Teams
  # ---------------------------------------------------------

  teams = {
    "Admin" = {
      name        = "Admin"
      description = "Admin Team"
      permission  = "admin"
      members     = {
        "mhosker" = {
          role = "maintainer"
        }
      }
    }
    "DevOps" = {
      name        = "DevOps"
      description = "DevOps Team"
      permission  = "push"
      members     = {
        "mhosker" = {
          role = "maintainer"
        }
        "example-user" = {
          role = "member"
        }
      }
    }
  }
}
```