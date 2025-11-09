#############################################################################
# VPC Module - Security Groups
#############################################################################
# This file defines security groups (firewalls) for different components:
# - EKS Cluster Security Group
# - EKS Node Security Group
# - ALB Security Group
#############################################################################

#############################################################################
# Security Group for EKS Cluster
#############################################################################

resource "aws_security_group" "eks_cluster" {
  name_prefix = "${var.project_name}-${var.environment}-eks-cluster-"
  description = "Security group for EKS cluster control plane"
  vpc_id      = aws_vpc.main.id

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-eks-cluster-sg"
      Project     = var.project_name
      Environment = var.environment
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Allow cluster to communicate with nodes
resource "aws_security_group_rule" "cluster_to_node" {
  description              = "Allow cluster to communicate with worker nodes"
  type                     = "egress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_nodes.id
}

# Allow nodes to communicate with cluster API (CRITICAL for node join)
resource "aws_security_group_rule" "node_to_cluster_ingress" {
  description              = "Allow worker nodes to communicate with cluster API"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_nodes.id
}

#############################################################################
# Security Group for EKS Worker Nodes
#############################################################################

resource "aws_security_group" "eks_nodes" {
  name_prefix = "${var.project_name}-${var.environment}-eks-nodes-"
  description = "Security group for EKS worker nodes"
  vpc_id      = aws_vpc.main.id

  tags = merge(
    {
      Name                                            = "${var.project_name}-${var.environment}-eks-nodes-sg"
      Project                                         = var.project_name
      Environment                                     = var.environment
      "kubernetes.io/cluster/${var.project_name}-${var.environment}" = "owned"
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Allow nodes to communicate with each other
resource "aws_security_group_rule" "node_to_node" {
  description              = "Allow nodes to communicate with each other"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_nodes.id
}

# Allow nodes to receive communication from cluster
resource "aws_security_group_rule" "cluster_to_node_ingress" {
  description              = "Allow worker nodes to receive communication from cluster"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_cluster.id
}

# Allow nodes to communicate with cluster API
resource "aws_security_group_rule" "node_to_cluster" {
  description              = "Allow worker nodes to communicate with cluster API"
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_cluster.id
}

# Allow nodes to access internet (for pulling images, etc.)
resource "aws_security_group_rule" "node_egress_internet" {
  description       = "Allow worker nodes to access internet"
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  security_group_id = aws_security_group.eks_nodes.id
  cidr_blocks       = ["0.0.0.0/0"]
}

# Allow nodes to receive traffic from ALB
resource "aws_security_group_rule" "alb_to_node" {
  description              = "Allow ALB to communicate with worker nodes"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.alb.id
}

#############################################################################
# Security Group for Application Load Balancer
#############################################################################

resource "aws_security_group" "alb" {
  name_prefix = "${var.project_name}-${var.environment}-alb-"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-alb-sg"
      Project     = var.project_name
      Environment = var.environment
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Allow inbound HTTP traffic from internet
resource "aws_security_group_rule" "alb_http_ingress" {
  description       = "Allow HTTP traffic from internet"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.alb.id
  cidr_blocks       = ["0.0.0.0/0"]
}

# Allow inbound HTTPS traffic from internet
resource "aws_security_group_rule" "alb_https_ingress" {
  description       = "Allow HTTPS traffic from internet"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.alb.id
  cidr_blocks       = ["0.0.0.0/0"]
}

# Allow outbound traffic to EKS nodes
resource "aws_security_group_rule" "alb_to_node_egress" {
  description              = "Allow ALB to communicate with worker nodes"
  type                     = "egress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.alb.id
  source_security_group_id = aws_security_group.eks_nodes.id
}
