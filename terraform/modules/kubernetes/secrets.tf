#############################################################################
# Kubernetes Module - Secrets
#############################################################################
# Create Kubernetes secrets for sensitive configuration data.
#############################################################################

# Secret for MongoDB connection URI
resource "kubernetes_secret" "mongodb" {
  metadata {
    name      = "mongodb-secret"
    namespace = kubernetes_namespace.app.metadata[0].name

    labels = {
      app         = var.project_name
      environment = var.environment
      managed-by  = "terraform"
    }
  }

  data = {
    mongodb-uri = var.mongodb_uri
  }

  type = "Opaque"
}

# Secret for application configuration
resource "kubernetes_secret" "app_config" {
  metadata {
    name      = "app-config"
    namespace = kubernetes_namespace.app.metadata[0].name

    labels = {
      app         = var.project_name
      environment = var.environment
      managed-by  = "terraform"
    }
  }

  data = {
    environment = var.environment
    node_env    = "production"
  }

  type = "Opaque"
}
