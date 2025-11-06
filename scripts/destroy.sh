#!/bin/bash

#######################################
# PureHouse - Destroy Script
#
# Destroys ALL AWS infrastructure to stop costs
# WARNING: This will delete everything!
#######################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
AWS_REGION="us-east-2"
PROJECT_NAME="purehouse"
ENV="production"

echo -e "${RED}========================================${NC}"
echo -e "${RED}  PureHouse - DESTROY Infrastructure${NC}"
echo -e "${RED}========================================${NC}"
echo ""

echo -e "${RED}⚠️  WARNING ⚠️${NC}"
echo ""
echo "This script will DELETE ALL AWS resources:"
echo "  - EKS Cluster"
echo "  - EC2 Worker Nodes"
echo "  - Application Load Balancer"
echo "  - VPC and Networking"
echo "  - ECR Images (optional)"
echo ""
echo -e "${YELLOW}This action CANNOT be undone!${NC}"
echo ""
read -p "Type 'destroy' to confirm: " confirm

if [ "$confirm" != "destroy" ]; then
    echo "Destroy cancelled."
    exit 0
fi

echo ""
echo -e "${GREEN}Starting destruction process...${NC}"
echo ""

# Check if kubectl is configured
if kubectl cluster-info &> /dev/null; then
    echo -e "${YELLOW}Step 1: Cleaning up Kubernetes resources${NC}"
    echo "========================================"
    
    # Delete ingress first (to remove ALB)
    echo "Deleting ingress (this removes the Load Balancer)..."
    kubectl delete ingress --all -n ${PROJECT_NAME}-${ENV} --ignore-not-found=true
    
    # Wait for ALB to be deleted
    echo "Waiting for Load Balancer to be deleted (this may take 2-3 minutes)..."
    sleep 30
    
    # Delete all other resources
    echo "Deleting applications..."
    kubectl delete all --all -n ${PROJECT_NAME}-${ENV} --ignore-not-found=true
    
    # Delete namespace
    echo "Deleting namespace..."
    kubectl delete namespace ${PROJECT_NAME}-${ENV} --ignore-not-found=true
    
    echo -e "${GREEN}✅ Kubernetes resources cleaned${NC}"
else
    echo -e "${YELLOW}ℹ️  Kubernetes cluster not accessible, skipping K8s cleanup${NC}"
fi

echo ""
echo -e "${YELLOW}Step 2: Destroying Terraform infrastructure${NC}"
echo "========================================"

cd terraform/environments/production

# Initialize Terraform (in case state changed)
echo "Initializing Terraform..."
terraform init

# Destroy
echo ""
echo "Planning destruction..."
terraform plan -destroy -out=destroy-plan

echo ""
echo -e "${RED}Last chance to cancel! Press Ctrl+C now or${NC}"
read -p "Press Enter to continue with destruction..."

echo ""
echo "Destroying infrastructure..."
terraform apply destroy-plan

echo -e "${GREEN}✅ Infrastructure destroyed${NC}"

cd ../../..

# Optional: Clean ECR images
echo ""
read -p "Delete ECR images as well? (yes/no): " delete_images

if [ "$delete_images" = "yes" ]; then
    echo ""
    echo -e "${YELLOW}Step 3: Cleaning ECR repositories${NC}"
    echo "========================================"
    
    for repo in frontend backend worker; do
        echo "Deleting images from ${PROJECT_NAME}-${repo}..."
        aws ecr batch-delete-image \
            --repository-name ${PROJECT_NAME}-${repo} \
            --region ${AWS_REGION} \
            --image-ids "$(aws ecr list-images \
                --repository-name ${PROJECT_NAME}-${repo} \
                --region ${AWS_REGION} \
                --query 'imageIds[*]' \
                --output json)" \
            2>/dev/null || echo "No images to delete in ${repo}"
    done
    
    echo -e "${GREEN}✅ ECR images deleted${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ✅ Destruction Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${GREEN}💰 AWS costs have stopped${NC}"
echo ""
echo "Remaining resources (minimal cost):"
echo "  - S3 bucket (terraform state): ~\$0.01/month"
echo "  - DynamoDB table (state locks): Free tier"
echo "  - ECR repositories (empty): Free"
echo ""
echo -e "${YELLOW}To deploy again in the future:${NC}"
echo "  ./scripts/deploy.sh"
echo ""
echo -e "${GREEN}Done!${NC}"
