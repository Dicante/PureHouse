#!/bin/bash

#######################################
# PureHouse - Status Check Script
#
# Shows current deployment status and costs
#######################################

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
AWS_REGION="us-east-2"
PROJECT_NAME="purehouse"
ENV="production"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  PureHouse - Status Check${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check AWS connection
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS credentials not configured"
    exit 1
fi

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo -e "${YELLOW}📊 AWS Infrastructure Status${NC}"
echo "----------------------------------------"

# Check EKS Cluster
echo -n "EKS Cluster: "
if aws eks describe-cluster --name ${PROJECT_NAME}-${ENV}-eks --region ${AWS_REGION} &> /dev/null; then
    STATUS=$(aws eks describe-cluster --name ${PROJECT_NAME}-${ENV}-eks --region ${AWS_REGION} --query 'cluster.status' --output text)
    echo -e "${GREEN}${STATUS}${NC}"
else
    echo "NOT FOUND"
fi

# Check EC2 Instances
echo -n "EC2 Worker Nodes: "
NODE_COUNT=$(aws ec2 describe-instances \
    --region ${AWS_REGION} \
    --filters "Name=tag:eks:cluster-name,Values=${PROJECT_NAME}-${ENV}-eks" "Name=instance-state-name,Values=running" \
    --query 'Reservations[*].Instances[*].[InstanceId]' \
    --output text | wc -l)
echo "${NODE_COUNT} running"

# Check Load Balancers
echo -n "Load Balancers: "
ALB_COUNT=$(aws elbv2 describe-load-balancers \
    --region ${AWS_REGION} \
    --query "LoadBalancers[?contains(LoadBalancerName, 'k8s-purehous')].LoadBalancerName" \
    --output text | wc -l)
echo "${ALB_COUNT} active"

echo ""
echo -e "${YELLOW}⚓ Kubernetes Status${NC}"
echo "----------------------------------------"

# Check if kubectl is configured
if kubectl cluster-info &> /dev/null 2>&1; then
    # Get pods
    echo "Pods:"
    kubectl get pods -n ${PROJECT_NAME}-${ENV} 2>/dev/null || echo "  Namespace not found"
    
    echo ""
    echo "Services:"
    kubectl get svc -n ${PROJECT_NAME}-${ENV} 2>/dev/null || echo "  No services found"
    
    echo ""
    echo "Ingress:"
    kubectl get ingress -n ${PROJECT_NAME}-${ENV} 2>/dev/null || echo "  No ingress found"
    
    # Get ALB URL
    echo ""
    echo -n "Application URL: "
    ALB_URL=$(kubectl get ingress -n ${PROJECT_NAME}-${ENV} -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
    if [ -n "$ALB_URL" ]; then
        echo -e "${GREEN}http://${ALB_URL}${NC}"
    else
        echo "Not available yet"
    fi
else
    echo "❌ Cannot connect to Kubernetes cluster"
    echo "Run: aws eks update-kubeconfig --region ${AWS_REGION} --name ${PROJECT_NAME}-${ENV}-eks"
fi

echo ""
echo -e "${YELLOW}💰 Estimated Hourly Cost${NC}"
echo "----------------------------------------"
echo "EKS Cluster: \$0.10/hour"
echo "EC2 Nodes (${NODE_COUNT}x t3.small): \$$(echo "${NODE_COUNT} * 0.02" | bc)/hour"
echo "ALB (${ALB_COUNT}): \$$(echo "${ALB_COUNT} * 0.02" | bc)/hour"
echo "----------------------------------------"
TOTAL_COST=$(echo "0.10 + (${NODE_COUNT} * 0.02) + (${ALB_COUNT} * 0.02)" | bc)
echo -e "Total: ${GREEN}\$${TOTAL_COST}/hour${NC} (~\$$(echo "${TOTAL_COST} * 730" | bc)/month)"

echo ""
echo -e "${YELLOW}📝 Quick Commands${NC}"
echo "----------------------------------------"
echo "View logs:     kubectl logs -n ${PROJECT_NAME}-${ENV} -l app=backend"
echo "Port forward:  kubectl port-forward -n ${PROJECT_NAME}-${ENV} svc/backend-service 3001:3001"
echo "Restart pods:  kubectl rollout restart deployment/backend -n ${PROJECT_NAME}-${ENV}"
echo "Destroy all:   ./scripts/destroy.sh"

echo ""
