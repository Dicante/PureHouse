#############################################################################
# Kubernetes Module - ConfigMaps
#############################################################################
# Create ConfigMaps for non-sensitive configuration data.
#############################################################################

resource "kubernetes_config_map" "app_config" {
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
    # Backend configuration
    BACKEND_PORT = "3001"
    API_PREFIX   = "api"
    
    # Worker configuration
    WORKER_PORT = "3002"
    
    # Frontend configuration
    FRONTEND_PORT = "3000"
  }
}
