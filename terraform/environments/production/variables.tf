#############################################################################
# Production Environment - Variables
#############################################################################
# This file defines all configurable parameters for the production environment.
#############################################################################

#############################################################################
# General
#############################################################################

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-2"
}

variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
  default     = "purehouse"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

#############################################################################
# VPC Configuration
#############################################################################

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["us-east-2a", "us-east-2b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway for all private subnets"
  type        = bool
  default     = true
}

#############################################################################
# EKS Configuration
#############################################################################

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.28"
}

variable "node_instance_types" {
  description = "Instance types for EKS worker nodes"
  type        = list(string)
  default     = ["t3.small"]
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 4
}

variable "node_disk_size" {
  description = "Disk size in GB for worker nodes"
  type        = number
  default     = 20
}

variable "enable_cluster_logging" {
  description = "Enable EKS cluster logging to CloudWatch"
  type        = bool
  default     = false
}

#############################################################################
# ECR Configuration
#############################################################################

variable "ecr_repositories" {
  description = "List of ECR repository names to create"
  type        = list(string)
  default     = ["frontend", "backend", "worker"]
}

variable "ecr_image_tag_mutability" {
  description = "Tag mutability setting for ECR repositories"
  type        = string
  default     = "MUTABLE"
}

variable "ecr_scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

variable "ecr_lifecycle_policy_days" {
  description = "Number of days to keep untagged images"
  type        = number
  default     = 7
}

variable "ecr_max_image_count" {
  description = "Maximum number of images to keep per repository"
  type        = number
  default     = 10
}

#############################################################################
# Kubernetes Configuration
#############################################################################

variable "mongodb_uri" {
  description = "MongoDB connection URI (MongoDB Atlas)"
  type        = string
  sensitive   = true
}

variable "install_alb_controller" {
  description = "Whether to install AWS Load Balancer Controller"
  type        = bool
  default     = true
}
