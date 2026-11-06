# ------------------------------------------------------------------
# PLATFORM TEAM OWNS THIS FILE  (GitHub)
# An "approved" code repository. Same rules as the AWS bucket,
# on a completely different platform.
# ------------------------------------------------------------------

variable "team" {
  description = "Product team that owns this repo (lowercase, e.g. billing)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{2,15}$", var.team))
    error_message = "Team must be 2-15 lowercase letters, numbers or dashes."
  }
}

variable "company" {
  description = "Which side of the merger owns this: acme or initech"
  type        = string

  validation {
    condition     = contains(["acme", "initech"], var.company)
    error_message = "GUARDRAIL: company must be acme or initech."
  }
}

variable "owner" {
  description = "Email of the person accountable for this repo"
  type        = string

  validation {
    condition     = can(regex("^[^@ ]+@[^@ ]+$", var.owner))
    error_message = "GUARDRAIL: every resource needs an owner email."
  }
}

variable "cost_center" {
  description = "Finance cost center"
  type        = string

  validation {
    condition     = length(trimspace(var.cost_center)) > 0
    error_message = "GUARDRAIL: cost_center is required."
  }
}

variable "environment" {
  description = "dev or prod"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be dev or prod."
  }
}

variable "public" {
  description = "Should this repo be public? (Platform policy: no.)"
  type        = bool
  default     = false

  validation {
    condition     = var.public == false
    error_message = "GUARDRAIL: public repositories are not allowed. Ask the platform team for an exception."
  }
}

resource "github_repository" "this" {
  name        = "${var.company}-${var.team}"
  description = "Owner: ${var.owner} | Cost center: ${var.cost_center} | Managed by Terraform"
  visibility  = "private" # always private
  auto_init   = true      # first commit with a README

  # GitHub's version of tags
  topics = [var.company, var.environment, "managed-by-terraform"]
}

output "repo_url" {
  value = github_repository.this.html_url
}
