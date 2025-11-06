#############################################################################
# ECR Module - Main Configuration
#############################################################################
# This file creates ECR repositories for storing Docker images.
# Each application (frontend, backend, worker) gets its own repository.
#############################################################################

#############################################################################
# ECR Repositories
#############################################################################

resource "aws_ecr_repository" "main" {
  for_each = toset(var.repositories)

  name                 = "${var.project_name}-${var.environment}-${each.key}"
  image_tag_mutability = var.image_tag_mutability

  # Enable image scanning for security vulnerabilities
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  # Enable encryption
  encryption_configuration {
    encryption_type = var.encryption_type
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-${each.key}"
      Project     = var.project_name
      Environment = var.environment
      Service     = each.key
    },
    var.tags
  )
}

#############################################################################
# ECR Lifecycle Policies
#############################################################################
# Automatically delete old/untagged images to save storage costs

resource "aws_ecr_lifecycle_policy" "main" {
  for_each = toset(var.repositories)

  repository = aws_ecr_repository.main[each.key].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the last ${var.max_image_count} images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = var.max_image_count
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Delete untagged images after ${var.lifecycle_policy_days} days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = var.lifecycle_policy_days
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

#############################################################################
# ECR Repository Policies
#############################################################################
# Allow EKS nodes to pull images from these repositories

data "aws_iam_policy_document" "ecr_read_policy" {
  for_each = toset(var.repositories)

  statement {
    sid    = "AllowPull"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability"
    ]
  }
}

resource "aws_ecr_repository_policy" "main" {
  for_each = toset(var.repositories)

  repository = aws_ecr_repository.main[each.key].name
  policy     = data.aws_iam_policy_document.ecr_read_policy[each.key].json
}
