#!/bin/bash

#######################################
# PureHouse - Status Check Script
#
# Shows current deployment status and costs
#######################################

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
AWS_REGION="us-east-2"
PROJECT_NAME="purehouse"
ENV="production"
CLUSTER_NAME="${PROJECT_NAME}-${ENV}"
KUBE_NAMESPACE="${PROJECT_NAME}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  PureHouse - Status Check${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check AWS connection
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}❌ AWS credentials not configured${NC}"
    exit 1
fi

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo -e "${YELLOW}📊 AWS Infrastructure Status${NC}"
echo "----------------------------------------"

# Check EKS Cluster
echo -n "EKS Cluster: "
if aws eks describe-cluster --name ${CLUSTER_NAME} --region ${AWS_REGION} &> /dev/null; then
    STATUS=$(aws eks describe-cluster --name ${CLUSTER_NAME} --region ${AWS_REGION} --query 'cluster.status' --output text)
    VERSION=$(aws eks describe-cluster --name ${CLUSTER_NAME} --region ${AWS_REGION} --query 'cluster.version' --output text)
    echo -e "${GREEN}${STATUS} (v${VERSION})${NC}"
else
    echo -e "${RED}NOT FOUND${NC}"
fi

# Check EC2 Instances
echo -n "EC2 Worker Nodes: "
NODE_COUNT=$(aws ec2 describe-instances \
    --region ${AWS_REGION} \
    --filters "Name=tag:eks:cluster-name,Values=${CLUSTER_NAME}" "Name=instance-state-name,Values=running" \
    --query 'Reservations[*].Instances[*].[InstanceId]' \
    --output text | wc -l | tr -d ' ')
echo "${NODE_COUNT} running"

# Check NAT Gateway
echo -n "NAT Gateway: "
NAT_COUNT=$(aws ec2 describe-nat-gateways \
    --region ${AWS_REGION} \
    --filter "Name=tag:Project,Values=${PROJECT_NAME}" "Name=state,Values=available" \
    --query 'NatGateways[*].NatGatewayId' \
    --output text | wc -l | tr -d ' ')
if [ "${NAT_COUNT}" -gt 0 ]; then
    echo -e "${GREEN}${NAT_COUNT} active${NC}"
else
    echo -e "${YELLOW}None (cost-saving mode)${NC}"
fi

# Check Load Balancers
echo -n "Load Balancers: "
ALB_COUNT=$(aws elbv2 describe-load-balancers \
    --region ${AWS_REGION} \
    --query "LoadBalancers[?contains(LoadBalancerName, 'k8s-${PROJECT_NAME}')].LoadBalancerName" \
    --output text 2>/dev/null | wc -l | tr -d ' ')
echo "${ALB_COUNT} active"

echo ""
echo -e "${YELLOW}⚓ Kubernetes Status${NC}"
echo "----------------------------------------"

# Check if kubectl is configured
if kubectl cluster-info &> /dev/null 2>&1; then
    # Get nodes
    echo "Nodes:"
    kubectl get nodes 2>/dev/null || echo -e "  ${RED}Cannot get nodes${NC}"
    
    echo ""
    echo "Pods in ${KUBE_NAMESPACE} namespace:"
    kubectl get pods -n ${KUBE_NAMESPACE} 2>/dev/null || echo -e "  ${YELLOW}Namespace not found or no pods${NC}"
    
    echo ""
    echo "Services:"
    kubectl get svc -n ${KUBE_NAMESPACE} 2>/dev/null || echo -e "  ${YELLOW}No services found${NC}"
    
    echo ""
    echo "Ingress:"
    kubectl get ingress -n ${KUBE_NAMESPACE} 2>/dev/null || echo -e "  ${YELLOW}No ingress found${NC}"
    
    # Get ALB URL
    echo ""
    echo -n "Application URL: "
    ALB_URL=$(kubectl get ingress -n ${KUBE_NAMESPACE} -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
    if [ -n "$ALB_URL" ]; then
        echo -e "${GREEN}http://${ALB_URL}${NC}"
    else
        echo -e "${YELLOW}Not available yet${NC}"
    fi
else
    echo -e "${RED}❌ Cannot connect to Kubernetes cluster${NC}"
    echo "Run: aws eks update-kubeconfig --region ${AWS_REGION} --name ${CLUSTER_NAME}"
fi

echo ""
echo -e "${YELLOW}💰 Estimated Costs${NC}"
echo "----------------------------------------"

# Calculate costs
EKS_COST=0
NODE_COST=0
ALB_COST=0
NAT_COST=0

# Check if cluster exists
if aws eks describe-cluster --name ${CLUSTER_NAME} --region ${AWS_REGION} &> /dev/null; then
    EKS_COST=0.10
    NODE_COST=$(echo "${NODE_COUNT} * 0.021" | bc -l 2>/dev/null || echo "0")
    ALB_COST=$(echo "${ALB_COUNT} * 0.025" | bc -l 2>/dev/null || echo "0")
    NAT_COST=$(echo "${NAT_COUNT} * 0.045" | bc -l 2>/dev/null || echo "0")
    
    echo "EKS Cluster: \$${EKS_COST}/hour (\$73/month)"
    echo "EC2 Nodes (${NODE_COUNT}x t3.small): \$${NODE_COST}/hour (~\$15/month each)"
    echo "ALB (${ALB_COUNT}): \$${ALB_COST}/hour (~\$18/month each)"
    echo "NAT Gateway (${NAT_COUNT}): \$${NAT_COST}/hour (~\$32/month each)"
    echo "----------------------------------------"
    
    TOTAL_HOURLY=$(echo "${EKS_COST} + ${NODE_COST} + ${ALB_COST} + ${NAT_COST}" | bc -l)
    TOTAL_MONTHLY=$(echo "${TOTAL_HOURLY} * 730" | bc -l)
    
    printf "Total: \$%.3f/hour (~\$%.0f/month)\n" ${TOTAL_HOURLY} ${TOTAL_MONTHLY}
else
    echo -e "${YELLOW}No infrastructure deployed${NC}"
    echo "VPC, ECR, S3: ~\$0.01/month"
fi

echo ""
echo -e "${GREEN}Done!${NC}"
echo -e "Total: ${GREEN}\$${TOTAL_COST}/hour${NC} (~\$$(echo "${TOTAL_COST} * 730" | bc)/month)"

echo ""
echo -e "${YELLOW}📝 Quick Commands${NC}"
echo "----------------------------------------"
echo "View logs:     kubectl logs -n ${PROJECT_NAME}-${ENV} -l app=backend"
echo "Port forward:  kubectl port-forward -n ${PROJECT_NAME}-${ENV} svc/backend-service 3001:3001"
echo "Restart pods:  kubectl rollout restart deployment/backend -n ${PROJECT_NAME}-${ENV}"
echo "Destroy all:   ./scripts/destroy.sh"

echo ""
