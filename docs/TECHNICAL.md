# PureHouse - Technical Documentation

> Comprehensive technical documentation for the PureHouse DevOps portfolio project

**Last Updated:** November 9, 2025

---

## Table of Contents

1. [Infrastructure Architecture](#infrastructure-architecture)
2. [Terraform Modules](#terraform-modules)
3. [CI/CD Pipeline](#cicd-pipeline)
4. [Automation Scripts](#automation-scripts)
5. [Security Implementation](#security-implementation)
6. [Cost Analysis](#cost-analysis)
7. [Troubleshooting](#troubleshooting)

---

## Infrastructure Architecture

### Overview

The PureHouse infrastructure is built on AWS using a production-grade, multi-AZ architecture designed for high availability, security, and cost efficiency.

### AWS Infrastructure Design

```
AWS Cloud (us-east-2 - Ohio)
│
├── VPC (10.0.0.0/16)
│   ├── Public Subnets (10.0.1.0/24, 10.0.2.0/24)
│   │   ├── Internet Gateway
│   │   └── NAT Gateway (for private subnet internet access)
│   │
│   └── Private Subnets (10.0.10.0/24, 10.0.20.0/24)
│       └── EKS Worker Nodes (isolated from internet)
│
├── EKS Cluster (Kubernetes 1.33)
│   ├── Managed Control Plane (AWS handles HA)
│   ├── Node Group (2x t3.small, multi-AZ)
│   ├── IRSA (IAM Roles for Service Accounts)
│   └── ALB Ingress Controller
│
├── ECR (Private Docker registries)
│   ├── purehouse-production-frontend
│   ├── purehouse-production-backend
│   └── purehouse-production-worker
│
└── IAM & Security
    ├── OIDC Provider (GitHub Actions authentication)
    ├── Cluster IAM Role
    ├── Node Group IAM Role
    └── ALB Controller IAM Role
```

### VPC Network Design

**Multi-AZ architecture across 2 availability zones:**

```
VPC CIDR: 10.0.0.0/16

┌─────────────────────────────────────────────────┐
│                       VPC                       │
│                                                 │
│  AZ: us-east-2a             AZ: us-east-2b      │
│  ┌────────────────┐         ┌────────────────┐  │
│  │ Public Subnet  │         │ Public Subnet  │  │
│  │ 10.0.1.0/24    │         │ 10.0.2.0/24    │  │
│  │                │         │                │  │
│  │ - IGW Access   │         │ - IGW Access   │  │
│  │ - NAT Gateway  │         │                │  │
│  │ - ALB (HA)     │         │ - ALB (HA)     │  │
│  └────────────────┘         └────────────────┘  │
│                                                 │
│  ┌────────────────┐         ┌────────────────┐  │
│  │ Private Subnet │         │ Private Subnet │  │
│  │ 10.0.10.0/24   │         │ 10.0.20.0/24   │  │
│  │ EKS Nodes      │         │ EKS Nodes      │  │
│  └────────────────┘         └────────────────┘  │
└─────────────────────────────────────────────────┘
```

**Design Rationale:**

- **Multi-AZ deployment** - Survives single AZ failures
- **Private node placement** - Enhanced security (nodes don't have public IPs)
- **NAT Gateway** - Allows private nodes to access internet for updates
- **Single NAT Gateway** - Cost optimization for demo workload (saves $32/month vs multi-AZ NAT)

### EKS Cluster Architecture

```
┌──────────────────────────────────────────┐
│           EKS Control Plane              │
│       (AWS Managed - Multi-AZ HA)        │
└────────────────────┬─────────────────────┘
                     │
          ┌──────────┴──────────┐
          │                     │
    ┌─────▼─────┐         ┌─────▼─────┐
    │  Node 1   │         │   Node 2  │
    │  t3.small │         │  t3.small │
    │  AZ: 2a   │         │  AZ: 2b   │
    └───────────┘         └───────────┘
```

**Configuration:**

- **Kubernetes Version**: 1.33 (standard support until July 2026)
- **Node Type**: t3.small (2 vCPU, 2GB RAM)
- **Scaling**: Min 2, Desired 2, Max 4
- **AMI**: Amazon Linux 2 EKS-optimized
- **Disk**: 20GB gp3

### Application Architecture

**Microservices pattern with three decoupled services:**

```
┌──────────────────────────────────────────────────┐
│           AWS Application Load Balancer          │
│         (Path-based routing to services)         │
└───────────┬──────────────────────────────────────┘
            │
    ┌───────┼────────┐
    │       │        │
    ▼       ▼        ▼
┌─────┐  ┌─────┐  ┌─────┐
│Front│  │Back │  │Work │      ┌──────────┐
│ end │──│ end │──│ er  │      │ MongoDB  │
│Next │  │Nest │  │Expr │─────▶│  Atlas   │
│ JS  │  │ JS  │  │ ess │      │ (Cloud)  │
└─────┘  └─────┘  └─────┘      └──────────┘
```

**Key Architectural Decisions:**

- **Frontend**: Next.js 14 with API rewrites for seamless backend communication
- **Backend**: NestJS for structured, scalable API with TypeScript
- **Worker**: Separate Express service for async tasks (decoupled for horizontal scaling)
- **Database**: External MongoDB Atlas (avoids managing database in cluster, simplifies destroy/redeploy)

### Kubernetes Resource Design

```
Namespace: purehouse
├── Deployments
│   ├── frontend (2 replicas)
│   ├── backend (2 replicas)
│   └── worker (1 replica)
├── Services
│   ├── frontend-service (ClusterIP)
│   ├── backend-service (ClusterIP)
│   └── worker-service (ClusterIP)
├── Ingress
│   └── purehouse-ingress (ALB)
├── ConfigMaps
│   └── aws-auth
└── Secrets
    └── app-secrets (MongoDB URI)
```

**Resource Allocation Strategy:**

| Service  | Replicas | CPU Request | Memory Request | Reasoning                         |
| -------- | -------- | ----------- | -------------- | --------------------------------- |
| Frontend | 2        | 100m        | 128Mi          | High traffic, needs HA            |
| Backend  | 2        | 100m        | 256Mi          | Stateless API, horizontal scaling |
| Worker   | 1        | 50m         | 128Mi          | Async tasks, not user-facing      |

**Health Check Implementation:**

- **Liveness probes**: Detect and restart crashed containers
- **Readiness probes**: Control traffic routing during deployments
- **Startup probes**: Handle slow application startup

---

## Terraform Modules

### Modular Design Philosophy

Created **reusable, composable modules** following DRY principles:

```
terraform/
├── modules/
│   ├── vpc/         # Networking layer
│   ├── eks/         # Compute layer
│   ├── ecr/         # Registry layer
│   └── kubernetes/  # Application layer
│
└── environments/
    └── production/  # Orchestrates all modules
```

### Module: VPC

**Responsibility**: Network infrastructure

**Resources Created**:

- VPC with DNS support
- 2 public + 2 private subnets
- Internet Gateway
- NAT Gateway (configurable)
- Route tables and associations
- Security groups (cluster, nodes, ALB)

**Key Variables**:

```hcl
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "availability_zones" {
  default = ["us-east-2a", "us-east-2b"]
}

variable "enable_nat_gateway" {
  default = true
}

variable "single_nat_gateway" {
  default = true  # Cost optimization
}
```

**Outputs**: VPC ID, subnet IDs, security group IDs

### Module: EKS

**Responsibility**: Kubernetes cluster

**Resources Created**:

- EKS cluster with IAM role
- Node group with launch template
- IRSA (IAM Roles for Service Accounts)
- Add-ons (VPC-CNI, CoreDNS, kube-proxy)

**Key Variables**:

```hcl
variable "kubernetes_version" {
  default = "1.33"  # Changed from 1.31 to avoid Extended Support charges
}

variable "node_instance_types" {
  default = ["t3.small"]
}

variable "node_desired_size" {
  default = 2
}
```

**Outputs**: Cluster endpoint, certificate, name, node role ARN

### Module: ECR

**Responsibility**: Container registries

**Resources Created**:

- 3 ECR repositories (frontend, backend, worker)
- Lifecycle policies (keep last 10 images)
- Repository policies for cross-account access

**Key Features**:

- Image scanning on push
- Tag mutability: MUTABLE (allows `latest` tag updates)
- Automatic cleanup of old images

**Outputs**: Repository URLs for each service

### Module: Kubernetes

**Responsibility**: K8s-level resources deployed via Terraform

**Resources Created**:

- Namespace (`purehouse`)
- ConfigMaps (aws-auth for GitHub Actions access)
- Secrets (MongoDB URI from Terraform variable)
- AWS Load Balancer Controller (via Helm)

**Dependencies**: Requires EKS cluster to exist

**Critical Configuration - aws-auth ConfigMap**:

```yaml
mapRoles:
  # EKS worker nodes
  - rolearn: arn:aws:iam::ACCOUNT_ID:role/eks-nodes-role
    username: system:node:{{EC2PrivateDNSName}}
    groups:
      - system:bootstrappers
      - system:nodes
  
  # GitHub Actions CI/CD (CRITICAL for automation)
  - rolearn: arn:aws:iam::914970129822:role/github-actions-role
    username: github-actions
    groups:
      - system:masters
```

### State Management

**Remote backend with locking:**

```hcl
terraform {
  backend "s3" {
    bucket         = "purehouse-terraform-state-us-east-2"
    key            = "production/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "purehouse-terraform-lock"
    encrypt        = true
  }
}
```

**Benefits:**

- Team collaboration ready
- Prevents concurrent modifications via DynamoDB locking
- State versioning enabled
- Encryption at rest (AES256)

### Technical Decisions Made

| Decision                 | Alternative Considered      | Reasoning                                            |
| ------------------------ | --------------------------- | ---------------------------------------------------- |
| **EKS over EC2**   | Self-managed K8s on EC2     | Managed control plane reduces ops overhead           |
| **MongoDB Atlas**  | Self-hosted in cluster      | External DB simplifies cluster destroy/recreate      |
| **Terraform**      | CloudFormation, Pulumi      | Industry standard, multi-cloud transferable          |
| **K8s 1.33**       | 1.31, 1.34                  | Standard support until Jul 2026, saves $22.30/deploy |
| **Private nodes**  | Public with Security Groups | Enhanced security, production best practice          |
| **t3.small nodes** | t3.medium                   | Adequate for demo, 50% cost savings                  |
| **ALB Ingress**    | NGINX Ingress               | Native AWS integration, easier SSL management        |

---

## CI/CD Pipeline

### Overview

Implemented **two-stage pipeline** using GitHub Actions with modern OIDC authentication (zero stored credentials).

### Pipeline Architecture

```
  ┌─────────────┐
  │ Git Push to │
  │    main     │
  └──────┬──────┘
         │
         ▼
┌─────────────────┐
│  CI Workflow    │
│ (Pull Requests) │
│                 │
│ 1. Lint code    │
│ 2. Run tests    │
│ 3. Validate     │
│    builds       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  CD Workflow    │
│ (Main branch)   │
│                 │
│ 1. Auth via     │
│    OIDC         │
│ 2. Build images │
│ 3. Push to ECR  │
│ 4. Deploy to    │
│    EKS          │
└─────────────────┘
```

### OIDC Authentication (Security Best Practice)

**Traditional Approach (Anti-pattern)**:

```yaml
# ❌ Long-lived credentials stored in GitHub
secrets:
  AWS_ACCESS_KEY_ID: "AKIA..."
  AWS_SECRET_ACCESS_KEY: "wJalr..."
```

**Issues:**

- Credentials can be stolen if leaked
- Manual rotation required
- No audit trail

**OIDC Approach (Modern Security)**:

```
┌──────────────┐
│   GitHub     │
│   Workflow   │
└──────┬───────┘
       │ 1. Request OIDC token
       ▼
┌──────────────┐
│   GitHub     │
│ OIDC Provider│ (https://token.actions.githubusercontent.com)
└──────┬───────┘
       │ 2. Issue signed JWT token
       ▼
┌──────────────┐
│   AWS STS    │ (Security Token Service)
│              │ 3. Verify token signature
└──────┬───────┘
       │ 4. Assume IAM role
       ▼
┌──────────────┐
│  Temporary   │ (Valid for 1 hour)
│  Credentials │
└──────────────┘
```

**Implementation**:

```yaml
permissions:
  id-token: write    # Required for OIDC
  contents: read

steps:
  - name: Configure AWS credentials
    uses: aws-actions/configure-aws-credentials@v4
    with:
      role-to-assume: arn:aws:iam::${{ secrets.AWS_ACCOUNT_ID }}:role/github-actions-role
      aws-region: us-east-2
```

**Benefits:**

- ✅ No stored credentials
- ✅ Automatic expiration (1 hour)
- ✅ Audit trail via CloudTrail
- ✅ AWS security best practice

### CI Workflow (Continuous Integration)

**Trigger**: Pull requests to `main`

**Jobs**:

1. **test-backend**

   - Install dependencies
   - Run Jest unit tests
   - Run Supertest e2e tests
2. **test-frontend**

   - Install dependencies
   - Build Next.js (validates TypeScript)
3. **test-worker**

   - Install dependencies
   - Run tests
4. **validate-terraform** (optional)

   - `terraform fmt -check`
   - `terraform validate`

**Strategy**: Runs in parallel for fast feedback, fails fast, blocks merge if any test fails.

### CD Workflow (Continuous Deployment)

**Trigger**: Push to `main` branch

**Jobs**:

**1. build-and-push**

```yaml
Steps:
1. Checkout code
2. Configure AWS credentials (OIDC)
3. Login to Amazon ECR
4. Build Docker images (multi-stage builds)
5. Tag images:
   - latest (always points to production)
   - git-sha-123abc (enables rollback)
6. Push to ECR repositories
```

**2. deploy**

```yaml
Steps:
1. Configure AWS credentials (OIDC)
2. Update kubeconfig for EKS cluster
3. Replace ACCOUNT_ID in manifests
4. Apply Kubernetes manifests
5. Wait for rollout completion
6. Get Ingress URL
```

### Deployment Strategy

**Rolling Update** (zero downtime):

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxUnavailable: 1    # Never take down all pods
    maxSurge: 1          # Create 1 extra pod during update
```

**Flow**:

1. Create new pod with new image
2. Wait for readiness probe to pass
3. Route traffic to new pod
4. Terminate old pod
5. Repeat for each replica

---

## Automation Scripts

### Overview

Created **4 production-ready automation scripts** with comprehensive error handling, retry logic, and user feedback.

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
- After complete infrastructure destruction (mode 2)
- When switching AWS accounts/regions

**Usage:**

```bash
./scripts/setup-aws.sh
# Interactive: confirms AWS account, creates resources
# Output: Shows created ARNs for GitHub configuration
```

### 2. deploy.sh - Intelligent Deployment

**Purpose**: Fully automated deployment from Docker build to live application.

**Workflow:**

**Phase 1: Pre-flight Checks**

- Validates AWS credentials (`aws sts get-caller-identity`)
- Checks MongoDB URI configuration
- Verifies required tools (terraform, kubectl, docker)

**Phase 2: Docker Build** (3 options)

- **Option 1 - Skip**: Use existing images in ECR (fastest, 0 min)
- **Option 2 - Standard**: Build locally and push (~15 min)
- **Option 3 - Buildx**: Multi-arch build for AMD64 (~20 min, required for t3.small)

**Phase 3: Terraform Deployment**

- Initializes backend with S3/DynamoDB
- Creates execution plan (`tfplan`)
- **Applies with automatic retry logic**:
  ```bash
  Max attempts: 3
  Delay between retries: 10 seconds
  Re-plans after failure (picks up EKS-created resources)
  Handles aws-auth ConfigMap timing issue automatically
  ```

**Phase 4: Kubernetes Configuration**

- Auto-configures kubectl with cluster credentials
- Verifies node connectivity
- Displays node status

**Phase 5: Application Deployment**

- Applies all Kubernetes manifests
- Waits for rollout completion with timeout
- Extracts and displays ALB URL

**Features:**

- ✅ 100% automated, no manual intervention
- ✅ Automatic retry for EKS aws-auth timing issues (most common problem)
- ✅ Cost warning before expensive resource creation
- ✅ Color-coded progress logging
- ✅ Safe error handling at each step

**Usage:**

```bash
./scripts/deploy.sh

# Interactive prompts:
# 1. "MongoDB configured?" → yes
# 2. "Build option?" → 1 (skip) / 2 (standard) / 3 (buildx)
# 3. "Continue deployment?" → yes

# Time: ~12 minutes (first deploy), ~10 minutes (redeploy with skip build)
```

### 3. destroy.sh - Safe Infrastructure Teardown

**Purpose**: Intelligently destroy AWS resources with two modes for different use cases.

**Pre-Cleanup Phase** (Critical for success):

```bash
1. Check if kubectl can connect to cluster
2. Delete all Ingress resources (releases ALB)
3. Delete all TargetGroupBindings (AWS LB Controller CRDs)
4. Remove finalizers from stuck resources
5. Wait 10 seconds for AWS cleanup propagation
```

**Why Pre-Cleanup is Critical:**

- Kubernetes Ingress creates AWS ALB via controller
- ALB has dependencies (Target Groups, Security Groups)
- TargetGroupBindings have finalizers that block deletion
- Without cleanup, namespace deletion hangs and times out
- Pre-cleanup ensures smooth, fast destruction in 7 minutes

**Mode 1: Destroy Expensive Resources Only** (~7 minutes)

Destroys:

- ✅ Kubernetes namespace and all resources
- ✅ EKS cluster and control plane ($73/month saved)
- ✅ EC2 worker nodes ($30/month saved)
- ✅ Application Load Balancer ($18/month saved)
- ✅ NAT Gateway ($32/month saved)

Keeps:

- ✅ VPC and subnets
- ✅ ECR repositories with images (enables fast redeploy)
- ✅ S3 Terraform state
- ✅ DynamoDB lock table
- ✅ Security Groups

**Result**: $153/month → $0.01/month
**Redeploy time**: ~10 minutes (uses existing Docker images)

**Mode 2: Destroy Everything** (~10 minutes)

Destroys everything from Mode 1 plus:

- VPC, subnets, route tables
- ECR repositories and all images
- Security Groups
- Internet Gateway

Does NOT destroy (manual safety):

- S3 Terraform state bucket
- DynamoDB lock table
- OIDC provider
- IAM roles

**Confirmation**: Type `destroy-everything` (extra safety for complete cleanup)

**Terraform Fallback Logic:**

If Terraform times out (common with EKS deletion):

```bash
1. Attempt terraform destroy with target
2. If fails, fallback to aws eks delete-cluster (AWS CLI)
3. Wait for cluster deletion: aws eks wait cluster-deleted
4. Clean up Terraform state: terraform state rm
5. Continue with remaining resources
```

**Usage:**

```bash
./scripts/destroy.sh

# Select mode:
# 1 → Cost-saving (recommended for demos)
# 2 → Complete cleanup

# Mode 1 confirmation: yes
# Mode 2 confirmation: destroy-everything
```

### 4. status.sh - Real-Time Infrastructure Visibility

**Purpose**: Comprehensive infrastructure status and cost estimation.

**Information Displayed:**

**1. AWS Infrastructure**

- EKS cluster status and Kubernetes version
- EC2 worker node count
- NAT Gateway status (detects cost-saving mode)
- ALB count

**2. Kubernetes Status** (if cluster accessible)

- Node list with status and version
- Pods in namespace with ready state
- Services and their endpoints
- Ingress with ALB URL

**3. Cost Estimation**

- EKS: $0.10/hour ($73/month)
- EC2 nodes: $0.042/hour per t3.small
- ALB: $0.025/hour per load balancer
- NAT: $0.045/hour per gateway
- **Total hourly and monthly costs**

**4. Quick Commands**

- Pre-formatted kubectl commands for logs
- Port-forward examples
- Destroy command reminder

**Features:**

- ✅ Works with or without active cluster
- ✅ Detects cost-saving mode (no NAT Gateway)
- ✅ Uses `bc` for precise cost calculations
- ✅ Color-coded output (green/yellow/red)
- ✅ Handles connection failures gracefully

**Usage:**

```bash
./scripts/status.sh
# No arguments needed
# Shows complete current state
# Safe to run anytime
```

---

## Security Implementation

### Secrets Management

**Kubernetes Secrets** for runtime:

- MongoDB connection string (base64 encoded)
- Service-to-service tokens (if needed)

**GitHub Secrets** for CI/CD:

- `AWS_ACCOUNT_ID` (not sensitive, but parameterized)
- `MONGODB_URI` (sensitive, injected at deploy time)

**No secrets in code**: All sensitive data externalized via environment variables or Terraform variables.

### IAM Role Design (Least Privilege)

**GitHub Actions Role**:

```json
Permissions:
├── ECR: PushImage, GetAuthorizationToken
├── EKS: DescribeCluster, UpdateKubeconfig
└── No EC2, VPC, or destructive permissions
```

**EKS Cluster Role**:

```json
Permissions:
├── Create/manage ENIs and security groups
├── Attach policies for EKS cluster management
└── No access to other AWS services
```

**Node Group Role**:

```json
Permissions:
├── Pull images from ECR
├── Write logs to CloudWatch
├── EC2 metadata access
└── No S3, DynamoDB, or other service access
```

### Network Security

**Security Group Rules:**

```
EKS Cluster Security Group:
- Inbound: Allow from ALB security group on pod ports
- Inbound: Allow inter-node communication
- Outbound: Allow all (for pulling images, updates)

Node Security Group:
- Inbound: Allow from cluster security group
- Inbound: Allow HTTPS for ECR pulls
- Outbound: Allow all (NAT Gateway for internet)

ALB Security Group:
- Inbound: Allow HTTP/HTTPS from 0.0.0.0/0
- Outbound: Allow to cluster security group
```

---

## Cost Analysis

### Monthly Cost Breakdown (K8s 1.33)

| Service           | Configuration   | Cost/Hour                                | Monthly Cost                            | Optimization       |
| ----------------- | --------------- | ---------------------------------------- | --------------------------------------- | ------------------ |
| EKS Control Plane | 1 cluster       | $0.10 | $73.00                           | Standard support (was $0.50 with v1.31) |                    |
| EC2 Instances     | 2× t3.small    | $0.084 | $61.00                          | Right-sized, spot-ready                 |                    |
| NAT Gateway       | 1 gateway       | $0.045 | $32.00                          | Single AZ, or removable                 |                    |
| ALB               | 1 load balancer | $0.025 | $18.00                          | Path-based routing                      |                    |
| ECR Storage       | ~5 GB           | -                                        | $0.50                                   | Lifecycle policies |
| VPC (IPs, etc)    | Public IPs      | $0.005 | $3.50                           | In-use vs idle pricing                  |                    |
| S3 + DynamoDB     | State           | -                                        | $0.01                                   | Minimal data       |
| **Total**   |                 | **~$0.27/hr** | **~$153/mo** | **On-demand destroy strategy**    |                    |

### Cost Per Deploy (60-hour infrastructure lifetime)

```
Before optimization (K8s 1.31):
- EKS Extended Support: $0.50/hr × 60 = $30.00
- EKS Standard: $0.10/hr × 60 = $6.00
- Other resources: ~$15.84
Total: $51.84 per deploy

After optimization (K8s 1.33):
- EKS Standard: $0.10/hr × 60 = $6.00
- Other resources: ~$15.84
Total: $21.84 per deploy

Savings: 58% ($30 saved per deploy)
```

**Note**: Actual measured cost per deploy is ~$11.54 based on real AWS usage, as infrastructure typically runs shorter than 60 hours per deploy cycle.

### Cost Optimization Strategies

**1. On-Demand Infrastructure**

```bash
Deploy for demos: ./scripts/deploy.sh
Destroy after: ./scripts/destroy.sh (mode 1)

AWS Credits: $85 ÷ $11.54/deploy = ~7-8 full deploys
```

**2. Kubernetes Version Selection**

- K8s 1.33: Standard support until Jul 2026 ($0.10/hr)
- K8s 1.31: Extended support charges ($0.50/hr)
- **Savings**: $0.40/hr = 80% reduction in EKS costs

**3. Right-Sized Resources**

- t3.small vs t3.medium: 50% savings
- Pod resource limits prevent overprovisioning
- Horizontal scaling only when needed

**4. Lifecycle Policies**

- ECR: Keep only last 10 images
- CloudWatch logs: Disabled by default
- S3 versioning without lifecycle (state files are tiny)

**5. Destroy Strategy**

- Mode 1: Keeps VPC/ECR, enables 10-min redeploy
- Mode 2: Complete cleanup for account closure
- Cost when destroyed: $0.01/month (just ECR storage)

---

## Troubleshooting

### Common Issues & Solutions

#### Issue: "ConfigMap aws-auth does not exist"

**Cause**: EKS creates aws-auth asynchronously after cluster creation. Terraform tries to update it too soon.

**Solution**: `deploy.sh` has automatic retry logic (3 attempts, 10s delay, re-plans after each failure)

**Manual Fix**:

```bash
# Re-run deploy script (idempotent)
./scripts/deploy.sh

# Or manually apply Terraform
cd terraform/environments/production
terraform apply
```

#### Issue: "Namespace deletion timeout"

**Cause**: Ingress and TargetGroupBindings have finalizers that block deletion.

**Solution**: `destroy.sh` pre-cleanup phase removes these automatically.

**Manual Fix**:

```bash
# Remove finalizers manually
kubectl patch ingress purehouse-ingress -n purehouse \
  -p '{"metadata":{"finalizers":[]}}' --type=merge

kubectl delete targetgroupbindings --all -n purehouse
```

#### Issue: "Terraform state lock"

**Cause**: Previous Terraform operation was canceled (Ctrl+C) and didn't release lock.

**Solution**: Scripts detect and can release automatically (with confirmation).

**Manual Fix**:

```bash
# List current locks
aws dynamodb scan --table-name purehouse-terraform-lock

# Force unlock (get ID from error message)
terraform force-unlock <lock-id>
```

#### Issue: "EKS cluster still exists after destroy"

**Cause**: AWS takes 2-5 minutes to delete cluster asynchronously.

**Solution**: `destroy.sh` uses `aws eks wait cluster-deleted` to wait automatically.

**Manual Fix**:

```bash
# Wait for deletion
aws eks wait cluster-deleted --name purehouse-production --region us-east-2

# Or check AWS console
```

#### Issue: "GitHub Actions authentication failed"

**Cause**: IAM role not in aws-auth ConfigMap, or OIDC trust policy incorrect.

**Solution**: Terraform automatically configures aws-auth. Verify with:

```bash
kubectl get configmap aws-auth -n kube-system -o yaml | grep github-actions

# Should show:
# rolearn: arn:aws:iam::914970129822:role/github-actions-role
# username: github-actions
```

**Manual Fix**:

```bash
# Re-apply Terraform kubernetes module
cd terraform/environments/production
terraform apply -target=module.kubernetes
```

### Best Practices

1. **Always use scripts**, not manual Terraform

   - Scripts have safety checks and error handling
   - Consistent state management
   - Automatic retry logic
2. **Check status before operations**

   - `./scripts/status.sh` shows current state
   - Prevents unexpected conflicts
   - Verifies cost-saving mode
3. **Use destroy mode 1 for demos**

   - Keeps ECR images for fast redeploy
   - Saves 99.99% of costs between demos
   - 10-minute redeploy vs 25-minute full deploy
4. **Monitor costs regularly**

   - `status.sh` shows real-time cost estimation
   - AWS Console billing dashboard
   - Set up budget alerts in AWS
5. **Commit frequently during development**

   - S3 backend auto-saves state
   - But verify with `terraform state list`
   - Keep local backup before major changes

### Debugging Commands

**Check infrastructure:**

```bash
# Cluster status
aws eks describe-cluster --name purehouse-production --region us-east-2

# Node status
kubectl get nodes -o wide

# Pod logs
kubectl logs -f deployment/backend -n purehouse
kubectl logs -f deployment/frontend -n purehouse
kubectl logs -f deployment/worker -n purehouse

# Events
kubectl get events -n purehouse --sort-by='.lastTimestamp'
```

**Check Terraform state:**

```bash
cd terraform/environments/production

# List all resources
terraform state list

# Show specific resource
terraform state show module.eks.aws_eks_cluster.main

# Refresh state
terraform refresh
```

**Check costs:**

```bash
# Real-time status
./scripts/status.sh

# AWS CLI cost explorer (if enabled)
aws ce get-cost-and-usage \
  --time-period Start=2024-11-01,End=2024-11-10 \
  --granularity DAILY \
  --metrics BlendedCost \
  --group-by Type=DIMENSION,Key=SERVICE
```

---

## Appendix

### Technology Stack

**Infrastructure:**

- AWS: EKS, ECR, VPC, ALB, IAM, S3, DynamoDB
- Terraform: v1.5+ with modular architecture
- Kubernetes: v1.33 on EKS
- Docker: Multi-stage builds

**CI/CD:**

- GitHub Actions: Workflows with OIDC
- Bash: Automation scripts with error handling

**Application:**

- Frontend: Next.js 14, TypeScript, Tailwind CSS
- Backend: NestJS 10, MongoDB Atlas, Mongoose
- Worker: Express.js, async processing

### File Locations

**Infrastructure as Code:**

- `terraform/modules/vpc/` - VPC, subnets, NAT, IGW
- `terraform/modules/eks/` - EKS cluster, node groups
- `terraform/modules/ecr/` - Container registries
- `terraform/modules/kubernetes/` - K8s resources via Terraform
- `terraform/environments/production/` - Production config

**Automation:**

- `scripts/setup-aws.sh` - Bootstrap AWS resources
- `scripts/deploy.sh` - Full deployment automation
- `scripts/destroy.sh` - Infrastructure teardown
- `scripts/status.sh` - Real-time monitoring

**Application:**

- `purehouse-frontend/` - Next.js application
- `purehouse-backend/` - NestJS API
- `purehouse-worker/` - Express worker service
- `kubernetes/` - K8s manifests (deployments, services, ingress)

**CI/CD:**

- `.github/workflows/ci.yml` - Tests on PRs
- `.github/workflows/cd.yml` - Deploy on main push

---

**Last Updated:** November 9, 2025
**Maintained by:** Julian Dicante

For high-level overview and portfolio presentation, see [README.md](../README.md).
