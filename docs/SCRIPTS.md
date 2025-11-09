# Automation Scripts Documentation

This document provides detailed information about the production-ready automation scripts that power PureHouse's infrastructure management.

## Overview

All scripts are designed to be **fully automated, idempotent, and production-ready** with comprehensive error handling, retry logic, and user feedback.

## Scripts

### 1. setup-aws.sh - One-Time Bootstrap

**Purpose**: Initialize AWS resources required for Terraform state management and CI/CD.

**What it creates:**
- **S3 Bucket**: `purehouse-terraform-state-us-east-2`
  - Versioning enabled for state history
  - Server-side encryption (AES256)
  - Lifecycle policy for old versions
  
- **DynamoDB Table**: `purehouse-terraform-lock`
  - Primary key: `LockID`
  - Prevents concurrent Terraform operations
  - Pay-per-request billing
  
- **OIDC Provider**: For GitHub Actions
  - URL: `https://token.actions.githubusercontent.com`
  - Thumbprint: GitHub's SSL certificate fingerprint
  - Enables passwordless GitHub → AWS authentication
  
- **IAM Role**: `github-actions-role`
  - Trust policy allows GitHub Actions to assume role
  - Permissions for EKS, ECR, Terraform operations
  - No long-lived credentials needed

**When to run:**
- Once before first deployment
- After complete infrastructure destruction (destroy mode 2)
- When switching AWS accounts/regions

**Usage:**
```bash
./scripts/setup-aws.sh
# Interactive: confirms AWS account, creates resources
# Output: Shows created ARNs for GitHub Actions configuration
```

---

### 2. deploy.sh - Intelligent Deployment

**Purpose**: Fully automated deployment from Docker build to live application.

**Workflow:**
1. **Pre-flight Checks**
   - Validates AWS credentials (`aws sts get-caller-identity`)
   - Checks MongoDB URI configuration
   - Verifies required tools (terraform, kubectl, docker)

2. **Docker Build Phase** (3 options)
   - **Option 1 - Skip**: Use existing images in ECR (fastest for redeploy)
   - **Option 2 - Standard**: Build locally and push (works on all platforms)
   - **Option 3 - Buildx**: Multi-arch build for AMD64 (required for t3.small nodes)

3. **Terraform Deployment**
   - Initializes backend with S3/DynamoDB
   - Creates execution plan (`tfplan`)
   - **Applies with automatic retry logic**:
     - Max 3 attempts
     - 10-second delay between retries
     - Re-plans after failure to pick up created resources
     - Handles EKS `aws-auth` ConfigMap timing issues

4. **Kubernetes Configuration**
   - Auto-configures kubectl with cluster credentials
   - Verifies node connectivity
   - Displays node status

5. **Application Deployment**
   - Applies all Kubernetes manifests
   - Waits for rollout completion with timeout
   - Extracts and displays ALB URL

**Features:**
- ✅ Fully automated, no manual intervention
- ✅ Automatic retry for known EKS timing issues
- ✅ Cost warning before expensive resource creation
- ✅ Detailed progress logging with color coding
- ✅ Safe error handling at each step

**Usage:**
```bash
./scripts/deploy.sh

# Interactive prompts:
# 1. "MongoDB configured?" → yes
# 2. "Build option?" → 1/2/3
# 3. "Continue deployment?" → yes

# Time: ~12-15 minutes
```

**Error Handling:**
- **aws-auth timing**: Automatic retry (most common issue)
- **State lock**: Fails gracefully with clear message
- **Missing MongoDB URI**: Warns but continues (env vars take precedence)
- **Build failures**: Stops before Terraform apply

---

### 3. destroy.sh - Safe Infrastructure Teardown

**Purpose**: Intelligently destroy AWS resources with two modes for different use cases.

**Pre-Cleanup Phase** (Critical for success):
1. Checks if kubectl can connect to cluster
2. Deletes all Ingress resources (releases ALB)
3. Deletes all TargetGroupBindings (AWS Load Balancer Controller CRDs)
4. Removes finalizers from stuck resources
5. Waits 10 seconds for AWS cleanup

**Why Pre-Cleanup is Needed:**
- Kubernetes Ingress creates AWS ALB via controller
- ALB has dependencies (Target Groups, Security Groups)
- TargetGroupBindings have finalizers that block deletion
- Without cleanup, namespace deletion hangs for 5+ minutes and times out
- Pre-cleanup ensures smooth, fast destruction

**Mode 1: Destroy Expensive Resources Only** (~7 minutes)

Destroys:
- ✅ Kubernetes namespace and all resources
- ✅ EKS cluster and control plane ($73/month)
- ✅ EC2 worker nodes ($30/month)
- ✅ Application Load Balancer ($18/month)
- ✅ NAT Gateway ($32/month)
- ✅ Elastic IP for NAT

Keeps:
- ✅ VPC and subnets
- ✅ ECR repositories with images
- ✅ S3 Terraform state
- ✅ DynamoDB lock table
- ✅ Security Groups
- ✅ Route tables

**Result**: $137/month → $0.01/month

**Redeploy time**: ~10 minutes (uses existing images)

**Mode 2: Destroy Everything** (~10 minutes)

Destroys absolutely everything:
- All Mode 1 resources
- VPC, subnets, route tables
- ECR repositories and all images
- Security Groups
- Internet Gateway

Does NOT destroy (must be manual):
- S3 Terraform state bucket (safety)
- DynamoDB lock table
- OIDC provider
- IAM roles

**Confirmation Required**: Type `destroy-everything` (safety measure)

**Terraform Fallback Logic:**

If Terraform times out (common with EKS deletion):
1. Attempts `terraform destroy` with target
2. If fails, falls back to `aws eks delete-cluster`
3. Waits for cluster deletion with `aws eks wait cluster-deleted`
4. Cleans up Terraform state manually with `terraform state rm`
5. Continues with remaining resources

**Usage:**
```bash
./scripts/destroy.sh

# Select mode:
# 1 → Cost-saving (keeps VPC/ECR)
# 2 → Complete cleanup

# Mode 1 confirmation: yes
# Mode 2 confirmation: destroy-everything
```

**Error Handling:**
- **Stuck namespace**: Pre-cleanup removes blocking resources
- **EKS timeout**: Fallback to AWS CLI direct deletion
- **State locks**: Auto-detection and release
- **Manual cleanup**: State removal for out-of-band deletions

---

### 4. status.sh - Real-Time Infrastructure Visibility

**Purpose**: Comprehensive infrastructure status and cost estimation.

**Information Displayed:**

1. **AWS Infrastructure**
   - EKS cluster status and Kubernetes version
   - EC2 worker node count
   - NAT Gateway status (detects cost-saving mode)
   - ALB count

2. **Kubernetes Status** (if cluster accessible)
   - Node list with status and version
   - Pods in namespace with ready state
   - Services and their endpoints
   - Ingress with ALB URL

3. **Cost Estimation**
   - EKS: $0.10/hour ($73/month)
   - EC2 nodes: $0.042/hour per t3.small
   - ALB: $0.025/hour per load balancer
   - NAT: $0.045/hour per gateway
   - **Total hourly and monthly costs**

4. **Quick Commands**
   - Pre-formatted kubectl commands for logs, port-forward
   - Destroy command for cleanup

**Features:**
- ✅ Works with or without active cluster
- ✅ Detects cost-saving mode (no NAT Gateway)
- ✅ Uses `bc` for precise cost calculations
- ✅ Color-coded output (green for success, red for issues)
- ✅ Handles connection failures gracefully

**Usage:**
```bash
./scripts/status.sh

# No arguments needed
# Shows complete current state
# Safe to run anytime
```

**Output Example:**
```
========================================
  PureHouse - Status Check
========================================

📊 AWS Infrastructure Status
----------------------------------------
EKS Cluster: ACTIVE (v1.31)
EC2 Worker Nodes: 2 running
NAT Gateway: 1 active
Load Balancers: 1 active

⚓ Kubernetes Status
----------------------------------------
Nodes: 2 Ready
Pods: 5/5 Running
Application URL: http://k8s-purehous-purehous-xxx.elb.amazonaws.com

💰 Estimated Costs
----------------------------------------
Total: $0.21/hour (~$153/month)
```

---

## Workflow Examples

### First-Time Setup
```bash
# 1. One-time AWS setup
./scripts/setup-aws.sh

# 2. Configure MongoDB
cd terraform/environments/production
cp terraform.tfvars.example terraform.tfvars
# Edit: add mongodb_uri

# 3. Deploy
cd ../../..
./scripts/deploy.sh
# yes → 3 (buildx) → yes
```

### Regular Demo Cycle
```bash
# Before demo
./scripts/deploy.sh
# yes → 1 (skip build) → yes
# Wait 10 minutes

# Show application
./scripts/status.sh
# Copy ALB URL

# After demo
./scripts/destroy.sh
# Option 1 → yes
# Wait 7 minutes
```

### Troubleshooting
```bash
# Check current state
./scripts/status.sh

# If deploy fails, retry safe (idempotent)
./scripts/deploy.sh

# If destroy hangs, scripts have auto-retry
# Check logs in /tmp/eks_destroy.log, /tmp/nat_destroy.log
```

## Script Reliability Features

### Error Handling
- **Exit on error**: `set -e` in all scripts
- **Fallback strategies**: AWS CLI if Terraform fails
- **Clear error messages**: Color-coded with context
- **Safe defaults**: Requires explicit confirmation for destructive operations

### Idempotency
- **Deploy**: Re-running creates missing resources only
- **Destroy**: Safe to re-run if partially complete
- **Status**: Read-only, always safe

### Logging
- **Color coding**: Green (success), Yellow (warning), Red (error)
- **Progress indicators**: "Still creating..." for long operations
- **File logs**: Critical operations log to `/tmp/`
- **State visibility**: Shows Terraform plan before apply

## Common Issues & Solutions

### Issue: "ConfigMap aws-auth does not exist"
**Cause**: EKS creates aws-auth asynchronously, Terraform tries to update too soon
**Solution**: deploy.sh has automatic retry (3 attempts, 10s delay)
**Manual Fix**: Re-run `./scripts/deploy.sh` or `terraform apply`

### Issue: "Namespace deletion timeout"
**Cause**: Ingress/TargetGroupBindings have finalizers
**Solution**: destroy.sh pre-cleanup removes these automatically
**Manual Fix**: `kubectl patch ingress <name> -p '{"metadata":{"finalizers":[]}}' --type=merge`

### Issue: "Terraform state lock"
**Cause**: Previous operation canceled (Ctrl+C)
**Solution**: Scripts detect and release automatically
**Manual Fix**: `terraform force-unlock <lock-id>`

### Issue: "EKS cluster still exists after destroy"
**Cause**: AWS takes 2-5 minutes to delete cluster
**Solution**: destroy.sh uses `aws eks wait cluster-deleted`
**Manual Fix**: Wait or check AWS console

## Best Practices

1. **Always use scripts**, not manual Terraform commands
   - Scripts have safety checks and error handling
   - Consistent state management

2. **Check status before deploy/destroy**
   - `./scripts/status.sh` shows current state
   - Prevents unexpected resource conflicts

3. **Use destroy mode 1 for demos**
   - Keeps ECR images for fast redeploy
   - Saves 99.99% of costs between demos

4. **Monitor costs with status.sh**
   - Real-time estimation
   - Detects if in cost-saving mode

5. **Commit state after changes**
   - S3 backend auto-saves
   - But good practice to verify with `terraform state list`

## Future Enhancements

Potential script improvements:

- [ ] Slack/Discord notifications on completion
- [ ] Automated testing before deployment
- [ ] Blue/green deployment support
- [ ] Backup/restore for MongoDB data
- [ ] Cost alerts if resources left running
- [ ] Scheduled destroy via cron/GitHub Actions

---

**Last Updated**: November 8, 2025  
**Maintained by**: Julian Dicante
