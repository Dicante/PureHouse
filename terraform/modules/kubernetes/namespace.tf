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
}
