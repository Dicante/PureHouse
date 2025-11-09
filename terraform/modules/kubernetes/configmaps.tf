#############################################################################
# Kubernetes Module - ConfigMaps
#############################################################################
# Create ConfigMaps for non-sensitive configuration data.
#############################################################################

# CRITICAL: aws-auth ConfigMap allows worker nodes to authenticate with cluster
resource "kubernetes_config_map_v1_data" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode([
      {
        rolearn  = var.node_role_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = [
          "system:bootstrappers",
          "system:nodes"
        ]
      }
    ])
    
    # Allow IAM users to access EKS console and kubectl
    mapUsers = yamlencode([
      {
        userarn  = "arn:aws:iam::914970129822:user/devops-user"
        username = "devops-user"
        groups   = ["system:masters"]
      }
    ])
  }

  force = true
}

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
