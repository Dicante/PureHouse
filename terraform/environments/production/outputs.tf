#############################################################################
# Production Environment - Outputs
#############################################################################
# These outputs display important information after deployment.
#############################################################################

#############################################################################
# VPC Outputs
#############################################################################

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_ips" {
  description = "Public IPs of NAT Gateways"
  value       = module.vpc.nat_gateway_public_ips
}

#############################################################################
# EKS Outputs
#############################################################################

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_version" {
  description = "Kubernetes version of the cluster"
  value       = module.eks.cluster_version
}

output "eks_node_group_id" {
  description = "ID of the EKS node group"
  value       = module.eks.node_group_id
}

output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

#############################################################################
# ECR Outputs
#############################################################################

output "ecr_repository_urls" {
  description = "URLs of ECR repositories"
  value       = module.ecr.repository_urls
}

output "frontend_image_uri" {
  description = "Full URI for frontend image"
  value       = "${module.ecr.frontend_repository_url}:latest"
}

output "backend_image_uri" {
  description = "Full URI for backend image"
  value       = "${module.ecr.backend_repository_url}:latest"
}

output "worker_image_uri" {
  description = "Full URI for worker image"
  value       = "${module.ecr.worker_repository_url}:latest"
}

#############################################################################
# Kubernetes Outputs
#############################################################################

output "kubernetes_namespace" {
  description = "Kubernetes namespace for the application"
  value       = module.kubernetes.namespace_name
}

output "alb_controller_installed" {
  description = "Whether AWS Load Balancer Controller is installed"
  value       = module.kubernetes.alb_controller_installed
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider"
  value       = module.kubernetes.oidc_provider_arn
}

#############################################################################
# Deployment Information
#############################################################################

output "deployment_summary" {
  description = "Summary of the deployment"
  value = <<-EOT
    
    ====================================================================
    PureHouse Infrastructure Deployment - ${var.environment}
    ====================================================================
    
    Region: ${var.aws_region}
    
    VPC:
      - VPC ID: ${module.vpc.vpc_id}
      - Public Subnets: ${length(module.vpc.public_subnet_ids)}
      - Private Subnets: ${length(module.vpc.private_subnet_ids)}
      - NAT Gateway IPs: ${join(", ", module.vpc.nat_gateway_public_ips)}
    
    EKS Cluster:
      - Cluster Name: ${module.eks.cluster_name}
      - Kubernetes Version: ${module.eks.cluster_version}
      - Node Group: ${module.eks.node_group_id}
      - Endpoint: ${module.eks.cluster_endpoint}
    
    ECR Repositories:
      - Frontend: ${module.ecr.frontend_repository_url}
      - Backend: ${module.ecr.backend_repository_url}
      - Worker: ${module.ecr.worker_repository_url}
    
    Kubernetes:
      - Namespace: ${module.kubernetes.namespace_name}
      - ALB Controller: ${module.kubernetes.alb_controller_installed ? "Installed" : "Not Installed"}
    
    Next Steps:
    1. Configure kubectl:
       aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}
    
    2. Verify cluster access:
       kubectl get nodes
    
    3. Check ALB controller:
       kubectl get pods -n kube-system | grep aws-load-balancer-controller
    
    4. Deploy applications:
       kubectl apply -f kubernetes/
    
    ====================================================================
  EOT
}
