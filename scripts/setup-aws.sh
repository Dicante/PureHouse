#!/bin/bash

#######################################
# PureHouse - AWS Initial Setup Script
# 
# This script sets up the initial AWS infrastructure required
# before Terraform can run:
# 1. S3 bucket for Terraform state
# 2. DynamoDB table for state locking
# 3. OIDC provider for GitHub Actions
# 4. IAM role for GitHub Actions
#
# Run this ONCE before first deployment
#######################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
AWS_REGION="us-east-2"
S3_BUCKET="purehouse-terraform-state-ohio"
DYNAMODB_TABLE="purehouse-terraform-locks"
GITHUB_ORG="Dicante" 
GITHUB_REPO="PureHouse"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  PureHouse - AWS Initial Setup${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI is not installed${NC}"
    echo "Install it: https://aws.amazon.com/cli/"
    exit 1
fi

# Check AWS credentials
echo -e "${YELLOW}🔍 Checking AWS credentials...${NC}"
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}❌ AWS credentials not configured${NC}"
    echo "Run: aws configure"
    exit 1
fi

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo -e "${GREEN}✅ AWS Account ID: ${AWS_ACCOUNT_ID}${NC}"
echo ""

# Confirm with user
echo -e "${YELLOW}⚠️  This script will create:${NC}"
echo "  1. S3 Bucket: ${S3_BUCKET}"
echo "  2. DynamoDB Table: ${DYNAMODB_TABLE}"
echo "  3. OIDC Provider for GitHub Actions"
echo ""
echo -e "${YELLOW}Region: ${AWS_REGION}${NC}"
echo ""
read -p "Continue? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Step 1: Creating S3 Bucket${NC}"
echo -e "${GREEN}========================================${NC}"

# Check if bucket exists
if aws s3 ls "s3://${S3_BUCKET}" 2>&1 | grep -q 'NoSuchBucket'; then
    echo "Creating S3 bucket: ${S3_BUCKET}"
    
    # Create bucket
    aws s3api create-bucket \
        --bucket "${S3_BUCKET}" \
        --region "${AWS_REGION}" \
        --create-bucket-configuration LocationConstraint="${AWS_REGION}"
    
    # Enable versioning
    aws s3api put-bucket-versioning \
        --bucket "${S3_BUCKET}" \
        --versioning-configuration Status=Enabled
    
    # Enable encryption
    aws s3api put-bucket-encryption \
        --bucket "${S3_BUCKET}" \
        --server-side-encryption-configuration '{
            "Rules": [{
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }]
        }'
    
    # Block public access
    aws s3api put-public-access-block \
        --bucket "${S3_BUCKET}" \
        --public-access-block-configuration \
            BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
    
    echo -e "${GREEN}✅ S3 bucket created and configured${NC}"
else
    echo -e "${YELLOW}ℹ️  S3 bucket already exists${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Step 2: Creating DynamoDB Table${NC}"
echo -e "${GREEN}========================================${NC}"

# Check if table exists
if ! aws dynamodb describe-table --table-name "${DYNAMODB_TABLE}" --region "${AWS_REGION}" &> /dev/null; then
    echo "Creating DynamoDB table: ${DYNAMODB_TABLE}"
    
    aws dynamodb create-table \
        --table-name "${DYNAMODB_TABLE}" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 \
        --region "${AWS_REGION}"
    
    echo "Waiting for table to be active..."
    aws dynamodb wait table-exists \
        --table-name "${DYNAMODB_TABLE}" \
        --region "${AWS_REGION}"
    
    echo -e "${GREEN}✅ DynamoDB table created${NC}"
else
    echo -e "${YELLOW}ℹ️  DynamoDB table already exists${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Step 3: Creating OIDC Provider${NC}"
echo -e "${GREEN}========================================${NC}"

# GitHub OIDC thumbprint (static value)
GITHUB_THUMBPRINT="6938fd4d98bab03faadb97b34396831e3780aea1"

# Check if OIDC provider exists
OIDC_PROVIDER_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"

if ! aws iam get-open-id-connect-provider --open-id-connect-provider-arn "${OIDC_PROVIDER_ARN}" &> /dev/null; then
    echo "Creating OIDC provider for GitHub Actions"
    
    aws iam create-open-id-connect-provider \
        --url "https://token.actions.githubusercontent.com" \
        --thumbprint-list "${GITHUB_THUMBPRINT}" \
        --client-id-list "sts.amazonaws.com"
    
    echo -e "${GREEN}✅ OIDC provider created${NC}"
else
    echo -e "${YELLOW}ℹ️  OIDC provider already exists${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Step 4: Creating IAM Role for GitHub${NC}"
echo -e "${GREEN}========================================${NC}"

ROLE_NAME="github-actions-role"

# Create trust policy
cat > /tmp/trust-policy.json <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "${OIDC_PROVIDER_ARN}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                },
                "StringLike": {
                    "token.actions.githubusercontent.com:sub": "repo:${GITHUB_ORG}/${GITHUB_REPO}:*"
                }
            }
        }
    ]
}
EOF

# Check if role exists
if ! aws iam get-role --role-name "${ROLE_NAME}" &> /dev/null; then
    echo "Creating IAM role: ${ROLE_NAME}"
    
    aws iam create-role \
        --role-name "${ROLE_NAME}" \
        --assume-role-policy-document file:///tmp/trust-policy.json \
        --description "Role for GitHub Actions to deploy PureHouse"
    
    # Attach policies
    echo "Attaching policies..."
    
    # Administrator access (for full Terraform control)
    # In production, you should use more restricted policies
    aws iam attach-role-policy \
        --role-name "${ROLE_NAME}" \
        --policy-arn "arn:aws:iam::aws:policy/AdministratorAccess"
    
    echo -e "${GREEN}✅ IAM role created and configured${NC}"
else
    echo -e "${YELLOW}ℹ️  IAM role already exists${NC}"
fi

rm -f /tmp/trust-policy.json

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ✅ Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}📋 Next Steps:${NC}"
echo ""
echo "1. Update GitHub repository secrets:"
echo "   Go to: https://github.com/${GITHUB_ORG}/${GITHUB_REPO}/settings/secrets/actions"
echo ""
echo "   Add these secrets:"
echo "   - AWS_ACCOUNT_ID: ${AWS_ACCOUNT_ID}"
echo "   - AWS_REGION: ${AWS_REGION}"
echo "   - AWS_ROLE_ARN: arn:aws:iam::${AWS_ACCOUNT_ID}:role/${ROLE_NAME}"
echo "   - MONGODB_URI: your_mongodb_atlas_connection_string"
echo "   - MONGODB_DB: purehouse"
echo ""
echo "2. Update terraform/environments/production/backend.tf:"
echo "   - bucket = \"${S3_BUCKET}\""
echo "   - dynamodb_table = \"${DYNAMODB_TABLE}\""
echo "   - region = \"${AWS_REGION}\""
echo ""
echo "3. Update scripts/setup-aws.sh:"
echo "   - GITHUB_ORG=\"${GITHUB_ORG}\""
echo ""
echo "4. Deploy infrastructure:"
echo "   ./scripts/deploy.sh"
echo ""
echo -e "${GREEN}Done!${NC}"
