#############################################################################
# ECR Module - Outputs
#############################################################################
# These values are exported so other modules and scripts can use them.
#############################################################################

output "repository_urls" {
  description = "Map of repository names to their URLs"
  value = {
    for repo in var.repositories :
    repo => aws_ecr_repository.main[repo].repository_url
  }
}

output "repository_arns" {
  description = "Map of repository names to their ARNs"
  value = {
    for repo in var.repositories :
    repo => aws_ecr_repository.main[repo].arn
  }
}

output "repository_registry_ids" {
  description = "Map of repository names to their registry IDs"
  value = {
    for repo in var.repositories :
    repo => aws_ecr_repository.main[repo].registry_id
  }
}

output "frontend_repository_url" {
  description = "URL of the frontend repository"
  value       = aws_ecr_repository.main["frontend"].repository_url
}

output "backend_repository_url" {
  description = "URL of the backend repository"
  value       = aws_ecr_repository.main["backend"].repository_url
}

output "worker_repository_url" {
  description = "URL of the worker repository"
  value       = aws_ecr_repository.main["worker"].repository_url
}
