#############################################################################
# EKS Module - Node Group
#############################################################################
# This file creates the EKS worker nodes (EC2 instances) that run your pods.
#############################################################################

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-${var.environment}-node-group"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = var.public_subnet_ids

  # Scaling configuration
  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  # Update configuration
  update_config {
    max_unavailable = 1
  }

  # Instance types
  instance_types = var.node_instance_types

  # Launch template configuration
  launch_template {
    name    = aws_launch_template.eks_nodes.name
    version = aws_launch_template.eks_nodes.latest_version
  }

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-eks-node-group"
      Project     = var.project_name
      Environment = var.environment
    },
    var.tags
  )

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_read_only,
  ]

  # Ignore changes to desired size (allow autoscaling)
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}

#############################################################################
# Launch Template for Worker Nodes
#############################################################################

resource "aws_launch_template" "eks_nodes" {
  name_prefix = "${var.project_name}-${var.environment}-eks-node-"
  description = "Launch template for EKS worker nodes"

  # Use latest EKS-optimized AMI
  image_id = data.aws_ssm_parameter.eks_ami.value

  # User data to bootstrap the node and join it to the cluster
  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    cluster_name        = aws_eks_cluster.main.name
    cluster_endpoint    = aws_eks_cluster.main.endpoint
    cluster_ca          = aws_eks_cluster.main.certificate_authority[0].data
    bootstrap_extra_args = ""
  }))

  # Network interface configuration (assign public IP for public subnets)
  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination       = true
    security_groups             = [var.node_security_group_id]
  }

  # Block device mapping (disk configuration)
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.node_disk_size
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }

  # Instance metadata service configuration
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  # Monitoring
  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      {
        Name        = "${var.project_name}-${var.environment}-eks-node"
        Project     = var.project_name
        Environment = var.environment
      },
      var.tags
    )
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      {
        Name        = "${var.project_name}-${var.environment}-eks-node-volume"
        Project     = var.project_name
        Environment = var.environment
      },
      var.tags
    )
  }

  lifecycle {
    create_before_destroy = true
  }
}

#############################################################################
# Data Source: Latest EKS-optimized AMI
#############################################################################

data "aws_ssm_parameter" "eks_ami" {
  name = "/aws/service/eks/optimized-ami/${var.kubernetes_version}/amazon-linux-2/recommended/image_id"
}
