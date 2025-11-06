#!/bin/bash

#######################################
# PureHouse - Deploy Script
#
# Deploys complete infrastructure to AWS:
# 1. Build and push Docker images to ECR
# 2. Deploy Terraform infrastructure
# 3. Deploy applications to Kubernetes
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
echo -e "${GREEN}  PureHouse - Deployment${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check prerequisites
echo -e "${YELLOW}🔍 Checking prerequisites...${NC}"

# Check AWS CLI
if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI not installed${NC}"
    exit 1
fi

# Check Terraform
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}❌ Terraform not installed${NC}"
    exit 1
fi

# Check kubectl
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl not installed${NC}"
    exit 1
fi

# Check Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker not installed${NC}"
    exit 1
fi

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}❌ AWS credentials not configured${NC}"
    exit 1
fi

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo -e "${GREEN}✅ AWS Account: ${AWS_ACCOUNT_ID}${NC}"

# Cost warning
echo ""
echo -e "${YELLOW}⚠️  COST WARNING${NC}"
echo "This will create AWS resources that cost approximately:"
echo "  - EKS Cluster: \$73/month (\$0.10/hour)"
echo "  - EC2 Nodes: \$30/month (\$0.04/hour)"
echo "  - ALB: \$16/month (\$0.02/hour)"
echo "  - Total: ~\$0.16/hour"
echo ""
read -p "Continue deployment? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Deployment cancelled."
    exit 0
fi

echo ""
echo -e "${GREEN}Step 1: Building Docker Images${NC}"
echo -e "${GREEN}========================================${NC}"

# Get ECR login
echo "Logging in to ECR..."
aws ecr get-login-password --region ${AWS_REGION} | \
    docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

# Build and push frontend
echo ""
echo "Building frontend..."
cd purehouse-frontend
docker build -t ${PROJECT_NAME}-frontend .
docker tag ${PROJECT_NAME}-frontend:latest \
    ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${PROJECT_NAME}-frontend:latest
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${PROJECT_NAME}-frontend:latest
cd ..

# Build and push backend
echo ""
echo "Building backend..."
cd purehouse-backend
docker build -t ${PROJECT_NAME}-backend .
docker tag ${PROJECT_NAME}-backend:latest \
    ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${PROJECT_NAME}-backend:latest
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${PROJECT_NAME}-backend:latest
cd ..

# Build and push worker
echo ""
echo "Building worker..."
cd purehouse-worker
docker build -t ${PROJECT_NAME}-worker .
docker tag ${PROJECT_NAME}-worker:latest \
    ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${PROJECT_NAME}-worker:latest
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${PROJECT_NAME}-worker:latest
cd ..

echo -e "${GREEN}✅ Docker images built and pushed${NC}"

echo ""
echo -e "${GREEN}Step 2: Deploying Terraform Infrastructure${NC}"
echo -e "${GREEN}========================================${NC}"

cd terraform/environments/production

# Initialize Terraform
echo "Initializing Terraform..."
terraform init

# Plan
echo ""
echo "Planning infrastructure changes..."
terraform plan -out=tfplan

# Apply
echo ""
read -p "Apply Terraform changes? (yes/no): " apply_confirm
if [ "$apply_confirm" = "yes" ]; then
    terraform apply tfplan
    echo -e "${GREEN}✅ Infrastructure deployed${NC}"
else
    echo "Terraform apply skipped."
    exit 0
fi

cd ../../..

echo ""
echo -e "${GREEN}Step 3: Configuring kubectl${NC}"
echo -e "${GREEN}========================================${NC}"

# Update kubeconfig
echo "Updating kubeconfig for EKS..."
aws eks update-kubeconfig \
    --region ${AWS_REGION} \
    --name ${PROJECT_NAME}-${ENV}-eks

# Verify connection
echo "Verifying cluster connection..."
kubectl get nodes

echo -e "${GREEN}✅ kubectl configured${NC}"

echo ""
echo -e "${GREEN}Step 4: Deploying Applications${NC}"
echo -e "${GREEN}========================================${NC}"

# Apply Kubernetes manifests
echo "Applying Kubernetes manifests..."

# Create namespace (if not exists)
kubectl create namespace ${PROJECT_NAME}-${ENV} --dry-run=client -o yaml | kubectl apply -f -

# Apply all manifests
kubectl apply -f kubernetes/frontend/ -n ${PROJECT_NAME}-${ENV}
kubectl apply -f kubernetes/backend/ -n ${PROJECT_NAME}-${ENV}
kubectl apply -f kubernetes/worker/ -n ${PROJECT_NAME}-${ENV}
kubectl apply -f kubernetes/ingress/ -n ${PROJECT_NAME}-${ENV}

echo ""
echo "Waiting for deployments to be ready..."
kubectl rollout status deployment/frontend -n ${PROJECT_NAME}-${ENV} --timeout=5m
kubectl rollout status deployment/backend -n ${PROJECT_NAME}-${ENV} --timeout=5m
kubectl rollout status deployment/worker -n ${PROJECT_NAME}-${ENV} --timeout=5m

echo -e "${GREEN}✅ Applications deployed${NC}"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ✅ Deployment Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Get ALB URL
echo "Fetching Application Load Balancer URL..."
ALB_URL=$(kubectl get ingress -n ${PROJECT_NAME}-${ENV} -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}')

if [ -n "$ALB_URL" ]; then
    echo -e "${GREEN}🌐 Application URL: http://${ALB_URL}${NC}"
    echo ""
    echo "Note: It may take 2-3 minutes for the ALB to be fully ready."
else
    echo -e "${YELLOW}⚠️  ALB URL not available yet. Run this command in a few minutes:${NC}"
    echo "kubectl get ingress -n ${PROJECT_NAME}-${ENV}"
fi

echo ""
echo -e "${YELLOW}📊 Check deployment status:${NC}"
echo "  ./scripts/status.sh"
echo ""
echo -e "${YELLOW}💥 To destroy infrastructure and stop costs:${NC}"
echo "  ./scripts/destroy.sh"
echo ""
echo -e "${GREEN}Done!${NC}"
