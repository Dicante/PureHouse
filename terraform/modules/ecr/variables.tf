#############################################################################
# ECR Module - Variables
#############################################################################
# This file defines all configurable parameters for the ECR module.
#############################################################################

variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., production, staging, development)"
  type        = string
}

variable "repositories" {
  description = "List of ECR repository names to create"
  type        = list(string)
  default     = ["frontend", "backend", "worker"]
}

variable "image_tag_mutability" {
  description = "Tag mutability setting for the repository (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "Encryption type to use (AES256 or KMS)"
  type        = string
  default     = "AES256"
}

variable "lifecycle_policy_days" {
  description = "Number of days to keep untagged images before deletion"
  type        = number
  default     = 7
}

variable "max_image_count" {
  description = "Maximum number of images to keep per repository"
  type        = number
  default     = 10
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
