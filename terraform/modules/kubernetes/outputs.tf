#############################################################################
# Kubernetes Module - Outputs
#############################################################################
# These values are exported for use by other modules or scripts.
#############################################################################

output "namespace_name" {
  description = "Name of the Kubernetes namespace created for the application"
  value       = kubernetes_namespace.app.metadata[0].name
}

output "mongodb_secret_name" {
  description = "Name of the MongoDB secret"
  value       = kubernetes_secret.mongodb.metadata[0].name
}

output "app_config_secret_name" {
  description = "Name of the application config secret"
  value       = kubernetes_secret.app_config.metadata[0].name
}

output "app_config_configmap_name" {
  description = "Name of the application config ConfigMap"
  value       = kubernetes_config_map.app_config.metadata[0].name
}

output "alb_controller_role_arn" {
  description = "ARN of the IAM role for AWS Load Balancer Controller"
  value       = var.install_alb_controller ? aws_iam_role.alb_controller[0].arn : null
}

output "alb_controller_installed" {
  description = "Whether AWS Load Balancer Controller is installed"
  value       = var.install_alb_controller
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider for the EKS cluster"
  value       = aws_iam_openid_connect_provider.eks.arn
}
