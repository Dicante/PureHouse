#############################################################################
# Kubernetes Module - Namespaces
#############################################################################
# Create Kubernetes namespaces for organizing resources.
#############################################################################

resource "kubernetes_namespace" "app" {
  metadata {
    name = var.project_name

    labels = {
      name        = var.project_name
      environment = var.environment
      managed-by  = "terraform"
    }
  }

  # Wait for the cluster to be fully ready before creating namespace
  depends_on = [
    kubernetes_config_map_v1_data.aws_auth
  ]
}
