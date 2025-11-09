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

# Check MongoDB URI
echo ""
echo -e "${YELLOW}🔍 Checking MongoDB configuration...${NC}"
if [ -z "$MONGODB_URI" ]; then
    echo -e "${YELLOW}⚠️  MONGODB_URI not set in environment${NC}"
    echo "Make sure you have the MongoDB URI configured in:"
    echo "  - GitHub Secrets (for CI/CD)"
    echo "  - Terraform variables (for local deploy)"
    echo ""
    read -p "Do you have MongoDB URI configured in Terraform/AWS? (yes/no): " mongo_confirm
    if [ "$mongo_confirm" != "yes" ]; then
        echo -e "${RED}❌ Please configure MongoDB URI first${NC}"
        echo "Add it to terraform.tfvars or set as GitHub Secret"
        exit 1
    fi
else
    echo -e "${GREEN}✅ MongoDB URI detected${NC}"
fi

# Docker build options
echo ""
echo -e "${YELLOW}🐳 Docker Build Configuration${NC}"
echo "Options:"
echo "  1. Skip build (use existing images in ECR)"
echo "  2. Build with standard Docker (faster, local architecture)"
echo "  3. Build with buildx for AMD64 (required for EKS t3.small nodes)"
echo ""
read -p "Select option (1/2/3): " build_option

case $build_option in
    1)
        echo -e "${GREEN}Skipping Docker build, will use existing images${NC}"
        SKIP_BUILD=true
        ;;
    2)
        echo -e "${YELLOW}Will use standard Docker build${NC}"
        SKIP_BUILD=false
        USE_BUILDX=false
        ;;
    3)
        echo -e "${GREEN}Will use buildx for AMD64 (recommended for EKS)${NC}"
        SKIP_BUILD=false
        USE_BUILDX=true
        ;;
    *)
        echo -e "${RED}Invalid option, defaulting to buildx AMD64${NC}"
        SKIP_BUILD=false
        USE_BUILDX=true
        ;;
esac

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

if [ "$SKIP_BUILD" = true ]; then
    echo -e "${YELLOW}Skipping Docker build as requested${NC}"
    echo "Will use existing images in ECR"
else
    # Get ECR login
    echo "Logging in to ECR..."
    aws ecr get-login-password --region ${AWS_REGION} | \
        docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

    if [ "$USE_BUILDX" = true ]; then
        echo -e "${GREEN}Using buildx for multi-platform build (AMD64)${NC}"
        
        # Setup buildx if not exists
        if ! docker buildx inspect purehouse-builder &>/dev/null; then
            echo "Creating buildx builder..."
            docker buildx create --name purehouse-builder --use
        else
            docker buildx use purehouse-builder
        fi
        
        # Build and load locally first, then push separately (faster)
        BUILD_COMMAND="docker buildx build --platform linux/amd64 --load"
        PUSH_NEEDED=true
    else
        echo -e "${YELLOW}Using standard Docker build${NC}"
        BUILD_COMMAND="docker build"
        PUSH_NEEDED=true
    fi

    # Build and push frontend
    echo ""
    echo "Building frontend..."
    cd purehouse-frontend
    IMAGE_NAME="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${PROJECT_NAME}-production-frontend:latest"
    
    if [ "$USE_BUILDX" = true ]; then
        $BUILD_COMMAND --build-arg NEXT_PUBLIC_API_URL=/api -t $IMAGE_NAME .
        echo "Pushing frontend image..."
        docker push $IMAGE_NAME
    else
        $BUILD_COMMAND --build-arg NEXT_PUBLIC_API_URL=/api -t ${PROJECT_NAME}-frontend .
        docker tag ${PROJECT_NAME}-frontend:latest $IMAGE_NAME
        docker push $IMAGE_NAME
    fi
    cd ..

    # Build and push backend
    echo ""
    echo "Building backend..."
    cd purehouse-backend
    IMAGE_NAME="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${PROJECT_NAME}-production-backend:latest"
    
    if [ "$USE_BUILDX" = true ]; then
        $BUILD_COMMAND -t $IMAGE_NAME .
        echo "Pushing backend image..."
        docker push $IMAGE_NAME
    else
        $BUILD_COMMAND -t ${PROJECT_NAME}-backend .
        docker tag ${PROJECT_NAME}-backend:latest $IMAGE_NAME
        docker push $IMAGE_NAME
    fi
    cd ..

    # Build and push worker
    echo ""
    echo "Building worker..."
    cd purehouse-worker
    IMAGE_NAME="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${PROJECT_NAME}-production-worker:latest"
    
    if [ "$USE_BUILDX" = true ]; then
        $BUILD_COMMAND -t $IMAGE_NAME .
        echo "Pushing worker image..."
        docker push $IMAGE_NAME
    else
        $BUILD_COMMAND -t ${PROJECT_NAME}-worker .
        docker tag ${PROJECT_NAME}-worker:latest $IMAGE_NAME
        docker push $IMAGE_NAME
    fi
    cd ..

    echo -e "${GREEN}✅ Docker images built and pushed${NC}"
fi

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

# Apply with retry logic for aws-auth ConfigMap timing issue
echo ""
echo "Applying Terraform changes automatically..."

MAX_RETRIES=3
RETRY_COUNT=0
APPLY_SUCCESS=false

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if terraform apply tfplan; then
        APPLY_SUCCESS=true
        echo -e "${GREEN}✅ Infrastructure deployed${NC}"
        break
    else
        RETRY_COUNT=$((RETRY_COUNT + 1))
        if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
            echo -e "${YELLOW}⚠️  Terraform apply failed (attempt $RETRY_COUNT/$MAX_RETRIES)${NC}"
            echo -e "${YELLOW}This is usually a timing issue with aws-auth ConfigMap...${NC}"
            echo -e "${YELLOW}Waiting 10 seconds and retrying...${NC}"
            sleep 10
            
            # Re-plan to pick up any resources that were created
            echo "Re-planning..."
            terraform plan -out=tfplan
        else
            echo -e "${RED}❌ Terraform apply failed after $MAX_RETRIES attempts${NC}"
            echo "Please check the errors above and try again"
            exit 1
        fi
    fi
done

if [ "$APPLY_SUCCESS" = false ]; then
    echo -e "${RED}❌ Infrastructure deployment failed${NC}"
    exit 1
fi

cd ../../..

echo ""
echo -e "${GREEN}Step 3: Configuring kubectl${NC}"
echo -e "${GREEN}========================================${NC}"

# Update kubeconfig
echo "Updating kubeconfig for EKS..."
aws eks update-kubeconfig \
    --region ${AWS_REGION} \
    --name ${PROJECT_NAME}-${ENV}

# Verify connection
echo "Verifying cluster connection..."
kubectl get nodes

echo -e "${GREEN}✅ kubectl configured${NC}"

echo ""
echo -e "${GREEN}Step 4: Deploying Applications${NC}"
echo -e "${GREEN}========================================${NC}"

# Apply Kubernetes manifests
echo "Applying Kubernetes manifests..."

# Note: Namespace is created by Terraform as 'purehouse'
KUBE_NAMESPACE="purehouse"

# Apply all manifests
kubectl apply -f kubernetes/frontend/ -n ${KUBE_NAMESPACE}
kubectl apply -f kubernetes/backend/ -n ${KUBE_NAMESPACE}
kubectl apply -f kubernetes/worker/ -n ${KUBE_NAMESPACE}
kubectl apply -f kubernetes/ingress/ -n ${KUBE_NAMESPACE}

echo ""
echo "Waiting for deployments to be ready..."
kubectl rollout status deployment/frontend -n ${KUBE_NAMESPACE} --timeout=5m
kubectl rollout status deployment/backend -n ${KUBE_NAMESPACE} --timeout=5m
kubectl rollout status deployment/worker -n ${KUBE_NAMESPACE} --timeout=5m

echo -e "${GREEN}✅ Applications deployed${NC}"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ✅ Deployment Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Get ALB URL
echo "Fetching Application Load Balancer URL..."
KUBE_NAMESPACE="purehouse"
ALB_URL=$(kubectl get ingress -n ${KUBE_NAMESPACE} -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}' 2>/dev/null)

if [ -n "$ALB_URL" ]; then
    echo -e "${GREEN}🌐 Application URL: http://${ALB_URL}${NC}"
    echo ""
    echo "Note: It may take 2-3 minutes for the ALB to be fully ready."
else
    echo -e "${YELLOW}⚠️  ALB URL not available yet. Run this command in a few minutes:${NC}"
    echo "kubectl get ingress -n ${KUBE_NAMESPACE}"
fi

echo ""
echo -e "${YELLOW}📊 Check deployment status:${NC}"
echo "  ./scripts/status.sh"
echo ""
echo -e "${YELLOW}� To save costs when not using:${NC}"
echo "  ./scripts/destroy.sh"
echo "  (Select option 1 to keep VPC/ECR for quick redeploy)"
echo ""
echo -e "${GREEN}Done!${NC}"
