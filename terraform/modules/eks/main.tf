#############################################################################
# EKS Module - Main Configuration
#############################################################################
# This file creates the EKS cluster (Kubernetes control plane).
#############################################################################

resource "aws_eks_cluster" "main" {
  name     = "${var.project_name}-${var.environment}"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = concat(var.private_subnet_ids, var.public_subnet_ids)
    endpoint_private_access = true
    endpoint_public_access  = true
    security_group_ids      = [var.cluster_security_group_id]
  }

  # Enable control plane logging (disabled by default to save costs)
  enabled_cluster_log_types = var.enable_cluster_logging ? var.cluster_log_types : []

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-eks-cluster"
      Project     = var.project_name
      Environment = var.environment
    },
    var.tags
  )

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_vpc_resource_controller,
  ]
}

#############################################################################
# EKS Cluster Add-ons
#############################################################################

# VPC CNI (networking) add-on
resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "vpc-cni"

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-vpc-cni"
      Project     = var.project_name
      Environment = var.environment
    },
    var.tags
  )
}

# CoreDNS add-on
resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "coredns"

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-coredns"
      Project     = var.project_name
      Environment = var.environment
    },
    var.tags
  )

  depends_on = [
    aws_eks_node_group.main
  ]
}

# kube-proxy add-on
resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "kube-proxy"

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-kube-proxy"
      Project     = var.project_name
      Environment = var.environment
    },
    var.tags
  )
}
