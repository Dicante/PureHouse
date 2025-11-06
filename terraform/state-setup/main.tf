#############################################################################
# Terraform State Setup
#############################################################################
# This file creates the necessary resources to store Terraform state:
# 1. S3 Bucket - To store the state file (terraform.tfstate)
# 2. DynamoDB Table - For state locking to prevent concurrent modifications
#
# IMPORTANT: This file is executed ONCE before everything else.
# After creating these resources, other Terraform files will use them.
#
# To execute this file:
#   cd terraform/state-setup
#   terraform init
#   terraform apply
#############################################################################

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = "state-setup"
      ManagedBy   = "Terraform"
    }
  }
}

#############################################################################
# Variables
#############################################################################

variable "aws_region" {
  description = "AWS region where the bucket will be created"
  type        = string
  default     = "us-east-2"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "purehouse"
}

variable "state_bucket_name" {
  description = "S3 bucket name for Terraform state"
  type        = string
  default     = "purehouse-terraform-state-ohio"
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for state locking"
  type        = string
  default     = "purehouse-terraform-locks"
}

#############################################################################
# S3 Bucket for Terraform State
#############################################################################

# Main bucket
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.state_bucket_name

  # Prevent accidental bucket deletion
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "Terraform State Bucket"
    Description = "Stores Terraform state for PureHouse"
  }
}

# Enable versioning (change history)
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Bucket encryption (security)
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access (security)
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle: delete old versions after 90 days
resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    id     = "delete-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

#############################################################################
# DynamoDB Table for State Locking
#############################################################################

resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"  # Pay only for what you use
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"  # String
  }

  # Prevent accidental table deletion
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "Terraform Lock Table"
    Description = "Prevents concurrent changes to Terraform state"
  }
}

#############################################################################
# Outputs
#############################################################################

output "state_bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.terraform_state.id
}

output "state_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.terraform_state.arn
}

output "dynamodb_table_name" {
  description = "Name of the created DynamoDB table"
  value       = aws_dynamodb_table.terraform_locks.id
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.terraform_locks.arn
}

output "backend_config" {
  description = "Backend configuration to use in other Terraform modules"
  value = <<-EOT
    
    Copy this configuration into your other Terraform files:
    
    terraform {
      backend "s3" {
        bucket         = "${aws_s3_bucket.terraform_state.id}"
        key            = "production/terraform.tfstate"
        region         = "${var.aws_region}"
        dynamodb_table = "${aws_dynamodb_table.terraform_locks.id}"
        encrypt        = true
      }
    }
  EOT
}
