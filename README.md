# PureHouse 🏠

> Full-stack blog application showcasing production-grade DevOps implementation on AWS

[![TypeScript](https://img.shields.io/badge/TypeScript-5.0-blue)](https://www.typescriptlang.org/)
[![Next.js](https://img.shields.io/badge/Next.js-14-black)](https://nextjs.org/)
[![NestJS](https://img.shields.io/badge/NestJS-10-red)](https://nestjs.com/)
[![Kubernetes](https://img.shields.## 📚 Documentation

- **[DevOps Architecture](docs/DEVOPS.md)** - Deep dive into infrastructure decisions and design patterns
- **[Automation Scripts](docs/SCRIPTS.md)** - Detailed documentation of all automation scripts, workflows, and troubleshooting
- **[Implementation Status](IMPLEMENTATION_STATUS.md)** - Complete feature checklist and project metricsadge/Kubernetes-1.31-326CE5)](https://kubernetes.io/)
[![Terraform](https://img.shields.io/badge/Terraform-1.5+-7B42BC)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-EKS-FF9900)](https://aws.amazon.com/eks/)

## � Quick Start

### Prerequisites

- AWS Account with credentials configured (`aws configure`)
- Terraform >= 1.5
- kubectl
- Docker Desktop (for building images)
- MongoDB Atlas account (free tier)

### First-Time Setup

```bash
# 1. Clone repository
git clone https://github.com/Dicante/PureHouse.git
cd PureHouse

# 2. Run one-time AWS setup (creates S3, DynamoDB, OIDC)
./scripts/setup-aws.sh

# 3. Configure MongoDB URI
cd terraform/environments/production
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars and add your MongoDB URI

# 4. Deploy complete infrastructure (~12 minutes)
cd ../../..
./scripts/deploy.sh
# Answer: yes → 1 (skip build if images exist) → yes
```

### Regular Usage

**Check Infrastructure Status**
```bash
./scripts/status.sh
# Shows: EKS cluster, nodes, pods, services, ALB URL, estimated costs
```

**Deploy/Redeploy**
```bash
./scripts/deploy.sh
# Fully automated with retry logic for EKS timing issues
# Build options: skip (use existing), standard, or multi-arch buildx
```

**Destroy Infrastructure**
```bash
./scripts/destroy.sh
# Option 1: Destroy expensive only (~$137/month → $0.01/month, ~7 min)
#           Keeps VPC, ECR, S3 for quick redeploy
# Option 2: Destroy EVERYTHING (complete cleanup, ~10 min)
```

### Cost-Saving Workflow

The scripts enable an efficient **on-demand infrastructure** pattern:

```bash
# After demo/testing - saves $137/month
./scripts/destroy.sh  # Select option 1
# ✅ Destroys: EKS cluster, EC2 nodes, ALB, NAT Gateway
# ✅ Keeps: VPC, ECR images, Terraform state

# When needed again - redeploys in ~10 minutes
./scripts/deploy.sh  # Select option 1 (skip build)
# ✅ Uses existing Docker images from ECR
# ✅ No need to rebuild or re-push containers
```

**With $100 AWS credits**: ~730 hours of demo time (30 days continuous, or 1 hour/day for 2 years!)

## 🎓 Key Learnings & Production Challenges Solved

This project demonstrates my ability to design, implement, and deploy a complete cloud-native application using modern DevOps practices. Built as a portfolio piece to showcase enterprise-level skills in cloud infrastructure, containerization, and automation.

### 🎯 Technical Achievements

- **Complete IaC Implementation**: Entire AWS infrastructure defined in Terraform with modular, reusable architecture
- **Production-Grade Kubernetes**: Multi-AZ EKS cluster with proper service mesh, ingress, and secrets management
- **Secure CI/CD Pipeline**: GitHub Actions with OIDC authentication (no stored credentials)
- **Microservices Design**: Decoupled services with proper API gateway pattern and async worker processing
- **Cost Optimization**: On-demand infrastructure with automated teardown (~$0.21/hour, deployable with $120 credits)
- **Type-Safe Full Stack**: End-to-end TypeScript implementation across all services
- **Observability**: Structured logging, health checks, and resource monitoring

## 🏗️ Architecture & Design Decisions

### Application Architecture

Implemented a **microservices pattern** with three decoupled services communicating through HTTP APIs:

```
┌──────────────────────────────────────────────────┐
│            AWS Application Load Balancer          │
│          (Path-based routing to services)         │
└───────────┬──────────────────────────────────────┘
            │
    ┌───────┼────────┐
    │       │        │
    ▼       ▼        ▼
┌─────┐ ┌─────┐ ┌─────┐
│Front│ │Back │ │Work │      ┌──────────┐
│ end │─│ end │─│ er  │      │ MongoDB  │
│Next │ │Nest │ │Expr │─────▶│  Atlas   │
│ JS  │ │ JS  │ │ ess │      │ (Cloud)  │
└─────┘ └─────┘ └─────┘      └──────────┘
```

**Key Architectural Decisions:**

- **Frontend**: Next.js 14 with API rewrites for seamless backend communication
- **Backend**: NestJS for structured, scalable API with TypeScript decorators
- **Worker**: Separate Express service for async tasks (decoupled for horizontal scaling)
- **Database**: External MongoDB Atlas (avoids managing database in cluster)

### AWS Infrastructure Design

Designed a **production-ready, multi-AZ Kubernetes environment** on AWS:

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
├── EKS Cluster (Kubernetes 1.31)
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

**Infrastructure Highlights:**

- **Multi-AZ for HA**: Resources spread across 2 availability zones
- **Private worker nodes**: Enhanced security with NAT gateway for outbound only
- **OIDC authentication**: No AWS credentials stored in GitHub (modern security)
- **Modular Terraform**: Reusable modules (VPC, EKS, ECR, Kubernetes)
- **State locking**: S3 + DynamoDB prevents concurrent modification issues

## 📁 Project Structure

```
PureHouse/
├── .github/workflows/          # CI/CD Automation
│   ├── ci.yml                  # Test & validate on PRs
│   └── cd.yml                  # Build & deploy on main push
│
├── docs/
│   └── DEVOPS.md               # DevOps architecture showcase
│
├── kubernetes/                 # K8s manifests (GitOps-ready)
│   ├── backend/deployment.yaml
│   ├── frontend/deployment.yaml
│   ├── worker/deployment.yaml
│   └── ingress/ingress.yaml    # ALB routing configuration
│
├── terraform/                  # Complete IaC implementation
│   ├── modules/
│   │   ├── vpc/                # Network infrastructure
│   │   ├── eks/                # Kubernetes cluster
│   │   ├── ecr/                # Container registries
│   │   └── kubernetes/         # K8s resources & ALB controller
│   ├── environments/
│   │   └── production/         # Production environment
│   └── state-setup/            # Terraform backend setup
│
├── scripts/                    # Production-ready automation
│   ├── setup-aws.sh            # One-time: S3, DynamoDB, OIDC, IAM roles
│   ├── deploy.sh               # Full deployment with auto-retry logic
│   ├── destroy.sh              # Smart destroy (2 modes with pre-cleanup)
│   └── status.sh               # Real-time infrastructure status & costs
│
├── purehouse-frontend/         # Next.js SSR application
├── purehouse-backend/          # NestJS REST API
└── purehouse-worker/           # Async processing service
```

## �️ Technical Implementation

### DevOps & Infrastructure

**Terraform Modules** (Reusable, Environment-Agnostic)

- `vpc`: Creates network with public/private subnets, NAT, IGW
- `eks`: Provisions managed Kubernetes with node groups and IRSA
- `ecr`: Sets up private Docker registries with lifecycle policies
- `kubernetes`: Deploys ALB controller, secrets, and namespaces

**CI/CD Pipeline** (GitHub Actions with OIDC)

```yaml
# Secure authentication without stored credentials
CI: Test → Lint → Build validation
CD: Build images → Push to ECR → Deploy to EKS
```

**Kubernetes Configuration**

- 2 replicas for frontend/backend (high availability)
- Resource limits prevent pod resource exhaustion
- Rolling updates with health checks (zero downtime)
- ClusterIP services with Ingress-based routing

### Application Stack

**Frontend** - Next.js 14 (React)

- Server-side rendering for SEO
- API routes with rewrites (proxy pattern)
- TypeScript for type safety
- Tailwind CSS for styling

**Backend** - NestJS (Node.js)

- RESTful API with decorators
- MongoDB integration with Mongoose
- Health checks at `/api/health`
- Worker HTTP client for async tasks

**Worker** - Express.js

- Lightweight processing service
- Colorized logging for visibility
- Health endpoint for K8s probes
- Async event handling

### Cost Optimization Strategy

Implemented **on-demand infrastructure** approach for maximum demo time with limited credits:

**Full Deployment Costs:**
- EKS Control Plane: $73/month ($0.10/hour)
- EC2 Nodes (2x t3.small): ~$30/month ($0.042/hour)  
- Application Load Balancer: ~$18/month ($0.025/hour)
- NAT Gateway: ~$32/month ($0.045/hour)
- **Total: ~$153/month or $0.21/hour**

**Cost-Saving Mode (After Destroy Option 1):**
- VPC components: $0.00/month
- ECR image storage: ~$0.01/month
- S3 Terraform state: ~$0.00/month
- **Total: ~$0.01/month**

**Demo Time Calculation:**
- With $100 AWS credits
- Full deployment: ~476 hours (19.8 days continuous)
- **Or:** 1 hour/day for 476 days (15.8 months!)
- **Or:** 8 hours/day for 59.5 days (2 months of work weeks)

**Automated workflow enables**:
- Destroy after each demo/interview (7 minutes)
- Redeploy before next demo (10 minutes)
- Maximum cost efficiency with minimal downtime

## � Key Learnings & Challenges

## 🎓 Key Learnings & Production Challenges Solved

### Real-World Infrastructure Challenges

1. **EKS aws-auth ConfigMap Timing Issue**
   - **Problem**: Terraform tries to update `aws-auth` before EKS creates it
   - **Solution**: Implemented automatic retry logic with 10s delay and re-planning
   - **Impact**: Deploy script now 100% automated, no manual intervention needed

2. **Kubernetes Resource Cleanup Blocking Destroy**
   - **Problem**: Ingress and TargetGroupBindings with finalizers blocked namespace deletion
   - **Solution**: Pre-cleanup script removes Ingress, ALB, Target Groups before Terraform destroy
   - **Impact**: Destroy process completes successfully in ~7 minutes without hanging

3. **Terraform State Locks from Canceled Operations**
   - **Problem**: Ctrl+C during apply left DynamoDB locks, blocking future operations
   - **Solution**: Scripts detect and auto-release stuck locks before operations
   - **Impact**: No more manual `terraform force-unlock` commands needed

4. **EKS Cluster Deletion Timing**
   - **Problem**: AWS takes 2-5 minutes to delete cluster, blocking redeploy
   - **Solution**: Destroy script uses `aws eks wait cluster-deleted` for automatic waiting
   - **Impact**: Reliable destroy → redeploy cycles without manual checks

5. **Cost Optimization Without Losing Images**
   - **Problem**: Full destroy meant rebuilding/pushing images (~10 min + Docker build time)
   - **Solution**: Two-tier destroy strategy (expensive-only vs everything)
   - **Impact**: Redeploy from $0.01/month to full stack in 10 min using existing images

### DevOps Skills Demonstrated

- ✅ **Cloud Architecture**: Complete AWS multi-AZ infrastructure from scratch
- ✅ **Infrastructure as Code**: Modular Terraform with proper state management
- ✅ **Kubernetes Production Patterns**: EKS, IRSA, ALB Ingress, proper resource cleanup
- ✅ **Automation & Scripting**: Robust bash scripts with error handling and retries
- ✅ **CI/CD Ready**: OIDC authentication, no stored credentials
- ✅ **Problem Solving**: Debugged and fixed real timing/race conditions
- ✅ **Cost Engineering**: On-demand infrastructure pattern for demos
- ✅ **Full-Stack Development**: TypeScript across Next.js, NestJS, Express

## 🔧 Automated Scripts Deep Dive

All scripts are **production-ready** with comprehensive error handling, retry logic, and user feedback.

### `deploy.sh` - Intelligent Deployment

**Features:**
- ✅ Pre-flight checks (AWS credentials, MongoDB config)
- ✅ Three build options: skip (existing images), standard, multi-arch buildx
- ✅ **Automatic retry** for EKS aws-auth ConfigMap timing (max 3 attempts)
- ✅ Terraform plan → apply with state locking
- ✅ Auto-configure kubectl and deploy K8s manifests
- ✅ Wait for deployments with rollout status
- ✅ Fetch and display ALB URL automatically

**Usage:**
```bash
./scripts/deploy.sh
# Interactive prompts guide you through:
# 1. MongoDB config confirmation
# 2. Build strategy selection
# 3. Cost warning acceptance
# Auto-completes in ~12 minutes
```

### `destroy.sh` - Safe Infrastructure Teardown

**Features:**
- ✅ **Pre-cleanup phase**: Removes Ingress, ALB, TargetGroupBindings before Terraform
- ✅ Two destruction modes:
  - **Mode 1** (Cost-Saving): Destroys EKS, nodes, ALB, NAT (~7 min, keeps VPC/ECR)
  - **Mode 2** (Complete): Destroys everything including VPC, ECR, S3
- ✅ **Fallback to AWS CLI** if Terraform times out on cluster deletion
- ✅ Automatic state cleanup for manually-deleted resources
- ✅ Different confirmation levels per mode (safety)

**Usage:**
```bash
./scripts/destroy.sh
# Select: 1 for cost-saving, 2 for complete cleanup
# Mode 1 saves $137/month, enables 10-min redeploy
```

### `status.sh` - Real-Time Infrastructure Visibility

**Features:**
- ✅ EKS cluster status and Kubernetes version
- ✅ EC2 worker node count
- ✅ NAT Gateway detection (cost-saving mode indicator)
- ✅ ALB count and status
- ✅ Pod health in namespace
- ✅ **Real-time cost estimation** with bc precision
- ✅ Application URL extraction from Ingress

**Usage:**
```bash
./scripts/status.sh
# Shows complete infrastructure state + estimated costs
# Detects if in cost-saving mode ($0.01/month)
```

### `setup-aws.sh` - One-Time Bootstrap

**Creates:**
- S3 bucket for Terraform state (versioned, encrypted)
- DynamoDB table for state locking
- OIDC provider for GitHub Actions (no credentials needed)
- IAM role for GitHub Actions with assume-role policy

**Run once before first deployment, or after complete destroy (mode 2)**

## � Documentation

- **[DevOps Architecture](docs/DEVOPS.md)** - Deep dive into infrastructure decisions
- **[CI/CD Workflows](.github/workflows/README.md)** - Pipeline implementation details

## 🔗 Project Links

- **Live Demo**: *[Currently deployed on-demand for demos]*
- **Repository**: [github.com/Dicante/PureHouse](https://github.com/Dicante/PureHouse)

## 👤 Author

**Julian Dicante**

Aspiring DevOps Engineer | Cloud Architecture | Kubernetes

- 🔗 LinkedIn: [linkedin.com/in/julian-dicante](linkedin.com/in/julian-dicante)
- 📧 Email: juliandicante@outlook.com

---

*This project was built as a portfolio piece to demonstrate production-grade DevOps implementation. It showcases my ability to design, implement, and deploy cloud-native applications using modern infrastructure practices.*
