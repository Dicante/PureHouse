#!/bin/bash

#######################################
# PureHouse - Destroy Script
#
# Options:
# 1. Destroy expensive resources only (keeps VPC, ECR, S3)
# 2. Destroy EVERYTHING (complete cleanup)
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

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  PureHouse - Destroy Infrastructure${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check prerequisites
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}❌ Terraform not installed${NC}"
    exit 1
fi

if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}❌ AWS credentials not configured${NC}"
    exit 1
fi

echo -e "${YELLOW}Select destroy mode:${NC}"
echo ""
echo "1. ${YELLOW}Destroy expensive resources only${NC} (recommended)"
echo "   - Destroys: EKS cluster, EC2 nodes, ALB, NAT Gateway"
echo "   - Keeps: VPC, ECR images, S3 state, Security Groups"
echo "   - Savings: ~\$151/month → \$0.01/month"
echo "   - Redeploy time: ~10 minutes"
echo ""
echo "2. ${RED}Destroy EVERYTHING${NC} (complete cleanup)"
echo "   - Destroys: All infrastructure including VPC, ECR, S3"
echo "   - WARNING: This removes Docker images and Terraform state"
echo "   - Use only when completely removing the project"
echo ""
read -p "Select option (1/2): " destroy_option

case $destroy_option in
    1)
        MODE="expensive"
        echo -e "${YELLOW}Mode: Destroy expensive resources only${NC}"
        ;;
    2)
        MODE="everything"
        echo -e "${RED}Mode: Destroy EVERYTHING${NC}"
        ;;
    *)
        echo -e "${RED}Invalid option. Exiting.${NC}"
        exit 1
        ;;
esac

# Confirmation
echo ""
if [ "$MODE" = "expensive" ]; then
    echo -e "${YELLOW}⚠️  This will destroy:${NC}"
    echo "  - EKS Cluster (save \$73/month)"
    echo "  - EC2 Nodes (save \$30/month)"
    echo "  - ALB (save \$16/month)"
    echo "  - NAT Gateway (save \$32/month)"
    echo ""
    echo -e "${GREEN}This will keep:${NC}"
    echo "  - VPC and subnets (for quick redeploy)"
    echo "  - ECR images (no need to rebuild)"
    echo "  - S3 Terraform state"
    echo ""
    read -p "Continue? (yes/no): " confirm
else
    echo -e "${RED}⚠️  WARNING: This will destroy EVERYTHING:${NC}"
    echo "  - EKS Cluster and all Kubernetes resources"
    echo "  - VPC, Subnets, NAT Gateway, Security Groups"
    echo "  - ECR repositories and ALL Docker images"
    echo "  - S3 bucket with Terraform state"
    echo "  - IAM roles and policies"
    echo ""
    echo -e "${RED}This action CANNOT be undone!${NC}"
    echo ""
    read -p "Type 'destroy-everything' to confirm: " confirm
    if [ "$confirm" != "destroy-everything" ]; then
        echo "Destruction cancelled."
        exit 0
    fi
fi

if [ "$confirm" != "yes" ] && [ "$confirm" != "destroy-everything" ]; then
    echo "Destruction cancelled."
    exit 0
fi

cd terraform/environments/production

# Function to handle terraform lock issues
handle_lock() {
    local lock_id=$(terraform force-unlock -help 2>&1 | grep -oE '[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}' | head -1)
    if [ -n "$lock_id" ]; then
        echo -e "${YELLOW}Detected stuck lock, releasing it...${NC}"
        terraform force-unlock -force "$lock_id" 2>/dev/null || true
    fi
}

if [ "$MODE" = "expensive" ]; then
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Destroying Expensive Resources${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    
    # Initialize Terraform
    echo -e "${YELLOW}Initializing Terraform...${NC}"
    terraform init
    
    # Pre-cleanup: Remove Kubernetes resources that block namespace deletion
    echo ""
    echo -e "${YELLOW}Pre-cleanup: Removing Kubernetes resources...${NC}"
    
    # Check if kubectl can connect to cluster
    if kubectl cluster-info &> /dev/null; then
        echo "Removing Ingress resources..."
        kubectl delete ingress --all -n purehouse --timeout=30s 2>/dev/null || true
        
        echo "Removing TargetGroupBindings..."
        kubectl delete targetgroupbindings --all -n purehouse --timeout=30s 2>/dev/null || true
        
        # Force remove finalizers if resources are stuck
        echo "Removing finalizers from stuck resources..."
        for ingress in $(kubectl get ingress -n purehouse -o name 2>/dev/null); do
            kubectl patch $ingress -n purehouse -p '{"metadata":{"finalizers":[]}}' --type=merge 2>/dev/null || true
        done
        
        for tgb in $(kubectl get targetgroupbindings -n purehouse -o name 2>/dev/null); do
            kubectl patch $tgb -n purehouse -p '{"metadata":{"finalizers":[]}}' --type=merge 2>/dev/null || true
        done
        
        echo "Waiting 10 seconds for resources to be removed..."
        sleep 10
    else
        echo "Cannot connect to cluster (already deleted or not configured)"
    fi
    
    # Target only expensive resources
    echo ""
    echo -e "${YELLOW}Destroying Kubernetes resources...${NC}"
    terraform destroy \
        -target=module.kubernetes \
        -auto-approve || echo "Kubernetes module already destroyed or doesn't exist"
    
    echo ""
    echo -e "${YELLOW}Destroying EKS cluster and nodes...${NC}"
    
    # First try with terraform
    terraform destroy \
        -target=module.eks \
        -auto-approve 2>&1 | tee /tmp/eks_destroy.log || {
        
        # If terraform times out, delete cluster manually via AWS CLI
        echo -e "${YELLOW}Terraform timed out, using AWS CLI to delete cluster...${NC}"
        
        # Delete cluster directly
        aws eks delete-cluster --name purehouse-production --region us-east-2 2>/dev/null || true
        
        # Wait for cluster to be deleted
        echo "Waiting for cluster deletion..."
        for i in {1..20}; do
            if ! aws eks describe-cluster --name purehouse-production --region us-east-2 &>/dev/null; then
                echo "Cluster deleted successfully"
                break
            fi
            echo "Still deleting... ($i/20)"
            sleep 15
        done
        
        # Remove resources from terraform state
        echo "Cleaning up Terraform state..."
        terraform state rm module.eks.aws_eks_cluster.main 2>/dev/null || true
        terraform state rm module.eks.aws_iam_role.eks_cluster 2>/dev/null || true
        terraform state rm module.eks.aws_iam_role.eks_nodes 2>/dev/null || true
        terraform state rm module.eks.aws_iam_role_policy_attachment.eks_cluster_policy 2>/dev/null || true
        terraform state rm module.eks.aws_iam_role_policy_attachment.eks_vpc_resource_controller 2>/dev/null || true
    }
    
    echo ""
    echo -e "${YELLOW}Destroying NAT Gateway...${NC}"
    
    # Delete NAT Gateway with terraform
    terraform destroy \
        -target=module.vpc.aws_nat_gateway.main \
        -target=module.vpc.aws_route.private_nat \
        -auto-approve 2>&1 | tee /tmp/nat_destroy.log || {
        
        # If terraform fails, clean up manually
        echo -e "${YELLOW}Cleaning up NAT Gateway from state...${NC}"
        terraform state rm 'module.vpc.aws_nat_gateway.main[0]' 2>/dev/null || true
        terraform state rm 'module.vpc.aws_route.private_nat[0]' 2>/dev/null || true
        terraform state rm 'module.vpc.aws_eip.nat[0]' 2>/dev/null || true
    }
    
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  ✅ Expensive resources destroyed!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${GREEN}Remaining infrastructure:${NC}"
    echo "  - VPC and subnets: ~\$0.00/month"
    echo "  - ECR images: ~\$0.01/month"
    echo "  - S3 state: ~\$0.00/month"
    echo ""
    echo -e "${YELLOW}Total monthly cost: ~\$0.01${NC}"
    echo ""
    echo -e "${GREEN}To redeploy, simply run:${NC}"
    echo "  ./scripts/deploy.sh"
    echo ""
    
else
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Destroying All Infrastructure${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    
    # Initialize Terraform
    echo -e "${YELLOW}Initializing Terraform...${NC}"
    terraform init
    
    # Destroy everything
    echo ""
    echo -e "${YELLOW}Destroying all Terraform resources...${NC}"
    terraform destroy -auto-approve
    
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  ✅ All resources destroyed!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${YELLOW}Note: S3 state bucket might still exist if it has contents.${NC}"
    echo "To remove it manually:"
    echo "  aws s3 rb s3://${PROJECT_NAME}-terraform-state-${AWS_REGION} --force"
    echo ""
fi

cd ../../..

echo -e "${GREEN}Done!${NC}"
