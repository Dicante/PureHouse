#############################################################################
# Production Environment - Main Configuration
#############################################################################
# This is the root module that orchestrates all infrastructure components.
# It calls all the child modules (VPC, EKS, ECR, Kubernetes) and wires
# them together to create the complete infrastructure.
#############################################################################

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }

  # Backend configuration for storing Terraform state in S3
  backend "s3" {
    bucket         = "purehouse-terraform-state-ohio"
    key            = "production/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "purehouse-terraform-locks"
    encrypt        = true
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

#############################################################################
# VPC Module
#############################################################################

module "vpc" {
  source = "../../modules/vpc"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway

  tags = var.tags
}

#############################################################################
# EKS Module
#############################################################################

module "eks" {
  source = "../../modules/eks"

  project_name              = var.project_name
  environment               = var.environment
  vpc_id                    = module.vpc.vpc_id
  private_subnet_ids        = module.vpc.private_subnet_ids
  public_subnet_ids         = module.vpc.public_subnet_ids
  cluster_security_group_id = module.vpc.eks_cluster_security_group_id
  node_security_group_id    = module.vpc.eks_nodes_security_group_id
  kubernetes_version        = var.kubernetes_version
  node_instance_types       = var.node_instance_types
  node_desired_size         = var.node_desired_size
  node_min_size             = var.node_min_size
  node_max_size             = var.node_max_size
  node_disk_size            = var.node_disk_size
  enable_cluster_logging    = var.enable_cluster_logging

  tags = var.tags

  depends_on = [module.vpc]
}

#############################################################################
# ECR Module
#############################################################################

module "ecr" {
  source = "../../modules/ecr"

  project_name           = var.project_name
  environment            = var.environment
  repositories           = var.ecr_repositories
  image_tag_mutability   = var.ecr_image_tag_mutability
  scan_on_push           = var.ecr_scan_on_push
  lifecycle_policy_days  = var.ecr_lifecycle_policy_days
  max_image_count        = var.ecr_max_image_count

  tags = var.tags
}

#############################################################################
# Kubernetes Module
#############################################################################

module "kubernetes" {
  source = "../../modules/kubernetes"

  project_name                       = var.project_name
  environment                        = var.environment
  cluster_name                       = module.eks.cluster_name
  cluster_endpoint                   = module.eks.cluster_endpoint
  cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
  cluster_oidc_issuer_url            = module.eks.cluster_oidc_issuer_url
  vpc_id                             = module.vpc.vpc_id
  mongodb_uri                        = var.mongodb_uri
  install_alb_controller             = var.install_alb_controller

  tags = var.tags

  depends_on = [module.eks]
}
