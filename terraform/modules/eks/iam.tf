#############################################################################
# EKS Module - IAM Roles
#############################################################################
# This file creates IAM roles and policies for:
# - EKS Cluster (control plane)
# - EKS Worker Nodes
#############################################################################

#############################################################################
# IAM Role for EKS Cluster
#############################################################################

# Trust policy: allow EKS service to assume this role
data "aws_iam_policy_document" "eks_cluster_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Create the IAM role for EKS cluster
resource "aws_iam_role" "eks_cluster" {
  name               = "${var.project_name}-${var.environment}-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume_role.json

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-eks-cluster-role"
      Project     = var.project_name
      Environment = var.environment
    },
    var.tags
  )
}

# Attach AWS managed policy for EKS cluster
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

# Attach AWS managed policy for EKS VPC resource controller
resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster.name
}

#############################################################################
# IAM Role for EKS Worker Nodes
#############################################################################

# Trust policy: allow EC2 service to assume this role
data "aws_iam_policy_document" "eks_node_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Create the IAM role for worker nodes
resource "aws_iam_role" "eks_nodes" {
  name               = "${var.project_name}-${var.environment}-eks-nodes-role"
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role.json

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-eks-nodes-role"
      Project     = var.project_name
      Environment = var.environment
    },
    var.tags
  )
}

# Attach AWS managed policy for EKS worker nodes
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes.name
}

# Attach AWS managed policy for EKS CNI (networking)
resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes.name
}

# Attach AWS managed policy for ECR read access (to pull images)
resource "aws_iam_role_policy_attachment" "eks_ecr_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name
}

# Attach AWS managed policy for SSM (optional, for debugging)
resource "aws_iam_role_policy_attachment" "eks_ssm_managed_instance" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.eks_nodes.name
}
