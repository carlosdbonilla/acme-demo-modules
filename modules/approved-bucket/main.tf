# ------------------------------------------------------------------
# PLATFORM TEAM OWNS THIS FILE  (AWS)
# An "approved" S3 bucket. Product teams use it; they can't skip the rules.
# ------------------------------------------------------------------

variable "team" {
  description = "Product team that owns this bucket (lowercase, e.g. billing)"
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
  description = "Email of the person accountable for this bucket"
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
  description = "Should this bucket be public? (Platform policy: no.)"
  type        = bool
  default     = false

  validation {
    condition     = var.public == false
    error_message = "GUARDRAIL: public buckets are not allowed. Ask the platform team for an exception."
  }
}

resource "aws_s3_bucket" "this" {
  bucket_prefix = "${var.company}-${var.team}-"
  force_destroy = true # demo only: lets 'terraform destroy' clean up

  tags = {
    Company     = var.company
    Team        = var.team
    Owner       = var.owner
    CostCenter  = var.cost_center
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Block all public access, always
resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Encrypt data at rest, always
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

output "bucket_name" {
  value = aws_s3_bucket.this.bucket
}
