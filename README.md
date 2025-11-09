# PureHouse - Production DevOps Portfolio 🚀# PureHouse 🏠



> **Full-stack blog application demonstrating enterprise-grade DevOps skills on AWS**> Full-stack blog application showcasing production-grade DevOps implementation on AWS



[![AWS EKS](https://img.shields.io/badge/AWS-EKS_1.33-FF9900?logo=amazon-aws)](https://aws.amazon.com/eks/)[![TypeScript](https://img.shields.io/badge/TypeScript-5.0-blue)](https://www.typescriptlang.org/)

[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.33-326CE5?logo=kubernetes)](https://kubernetes.io/)[![Next.js](https://img.shields.io/badge/Next.js-14-black)](https://nextjs.org/)

[![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC?logo=terraform)](https://www.terraform.io/)[![NestJS](https://img.shields.io/badge/NestJS-10-red)](https://nestjs.com/)

[![TypeScript](https://img.shields.io/badge/TypeScript-Full_Stack-3178C6?logo=typescript)](https://www.typescriptlang.org/)[![Kubernetes](https://img.shields.## 📚 Documentation

[![CI/CD](https://img.shields.io/badge/CI/CD-GitHub_Actions-2088FF?logo=github-actions)](https://github.com/features/actions)

- **[DevOps Architecture](docs/DEVOPS.md)** - Deep dive into infrastructure decisions and design patterns

---- **[Automation Scripts](docs/SCRIPTS.md)** - Detailed documentation of all automation scripts, workflows, and troubleshooting

- **[Implementation Status](IMPLEMENTATION_STATUS.md)** - Complete feature checklist and project metricsadge/Kubernetes-1.31-326CE5)](https://kubernetes.io/)

## 🎯 Why This Project Stands Out[![Terraform](https://img.shields.io/badge/Terraform-1.5+-7B42BC)](https://www.terraform.io/)

[![AWS](https://img.shields.io/badge/AWS-EKS-FF9900)](https://aws.amazon.com/eks/)

**Built to demonstrate real-world DevOps engineering skills**, not just tutorials. This project showcases:

## � Quick Start

✅ **Complete AWS infrastructure** designed from scratch using Terraform  

✅ **Production-ready Kubernetes** on EKS with multi-AZ high availability  ### Prerequisites

✅ **Automated CI/CD pipeline** with modern OIDC authentication (zero stored credentials)  

✅ **Cost optimization** - Reduced infrastructure costs by 66% through architecture decisions  - AWS Account with credentials configured (`aws configure`)

✅ **100% automation** - Deploy and destroy complete infrastructure with single commands  - Terraform >= 1.5

✅ **Real problem-solving** - Overcame production challenges like EKS timing issues and resource cleanup- kubectl

- Docker Desktop (for building images)

---- MongoDB Atlas account (free tier)



## 💼 DevOps Skills Demonstrated### First-Time Setup



<table>```bash

<tr># 1. Clone repository

<td width="50%">git clone https://github.com/Dicante/PureHouse.git

cd PureHouse

### Cloud Infrastructure

- ✅ AWS EKS cluster design & management# 2. Run one-time AWS setup (creates S3, DynamoDB, OIDC)

- ✅ Multi-AZ VPC architecture./scripts/setup-aws.sh

- ✅ Application Load Balancer with path routing

- ✅ IAM roles with least-privilege principle# 3. Configure MongoDB URI

- ✅ Cost engineering ($33/deploy → $11/deploy)cd terraform/environments/production

cp terraform.tfvars.example terraform.tfvars

</td># Edit terraform.tfvars and add your MongoDB URI

<td width="50%">

# 4. Deploy complete infrastructure (~12 minutes)

### Automation & IaCcd ../../..

- ✅ Modular Terraform architecture./scripts/deploy.sh

- ✅ Remote state management (S3 + DynamoDB)# Answer: yes → 1 (skip build if images exist) → yes

- ✅ Bash automation scripts with retry logic```

- ✅ GitHub Actions CI/CD pipelines

- ✅ OIDC authentication (no AWS keys in GitHub)### Regular Usage



</td>**Check Infrastructure Status**

</tr>```bash

<tr>./scripts/status.sh

<td width="50%"># Shows: EKS cluster, nodes, pods, services, ALB URL, estimated costs

```

### Kubernetes

- ✅ EKS cluster with managed node groups**Deploy/Redeploy**

- ✅ Deployments with rolling update strategy```bash

- ✅ Ingress controllers (AWS ALB Controller)./scripts/deploy.sh

- ✅ ConfigMaps & Secrets management# Fully automated with retry logic for EKS timing issues

- ✅ Health checks & resource limits# Build options: skip (use existing), standard, or multi-arch buildx

```

</td>

<td width="50%">**Destroy Infrastructure**

```bash

### Development & Operations./scripts/destroy.sh

- ✅ Microservices architecture (3 services)# Option 1: Destroy expensive only (~$137/month → $0.01/month, ~7 min)

- ✅ Containerization with multi-stage builds#           Keeps VPC, ECR, S3 for quick redeploy

- ✅ Private ECR registries with lifecycle policies# Option 2: Destroy EVERYTHING (complete cleanup, ~10 min)

- ✅ Full-stack TypeScript (Next.js, NestJS, Express)```

- ✅ MongoDB Atlas integration

### Cost-Saving Workflow

</td>

</tr>The scripts enable an efficient **on-demand infrastructure** pattern:

</table>

```bash

---# After demo/testing - saves $137/month

./scripts/destroy.sh  # Select option 1

## 🏗️ Architecture Overview# ✅ Destroys: EKS cluster, EC2 nodes, ALB, NAT Gateway

# ✅ Keeps: VPC, ECR images, Terraform state

```

┌─────────────────────────────────────────────────────────────┐# When needed again - redeploys in ~10 minutes

│                        Internet                              │./scripts/deploy.sh  # Select option 1 (skip build)

└────────────────────────┬────────────────────────────────────┘# ✅ Uses existing Docker images from ECR

                         │# ✅ No need to rebuild or re-push containers

                         ▼```

              ┌─────────────────────┐

              │   Application LB    │**With $100 AWS credits**: ~730 hours of demo time (30 days continuous, or 1 hour/day for 2 years!)

              │  (Path-based routing)│

              └──────────┬───────────┘## 🎓 Key Learnings & Production Challenges Solved

                         │

        ┌────────────────┼────────────────┐This project demonstrates my ability to design, implement, and deploy a complete cloud-native application using modern DevOps practices. Built as a portfolio piece to showcase enterprise-level skills in cloud infrastructure, containerization, and automation.

        │                │                │

        ▼                ▼                ▼### 🎯 Technical Achievements

   ┌────────┐      ┌────────┐      ┌────────┐

   │Frontend│      │Backend │      │ Worker │- **Complete IaC Implementation**: Entire AWS infrastructure defined in Terraform with modular, reusable architecture

   │Next.js │─────▶│NestJS  │◀─────│Express │- **Production-Grade Kubernetes**: Multi-AZ EKS cluster with proper service mesh, ingress, and secrets management

   │        │      │        │      │        │- **Secure CI/CD Pipeline**: GitHub Actions with OIDC authentication (no stored credentials)

   └────────┘      └────┬───┘      └────────┘- **Microservices Design**: Decoupled services with proper API gateway pattern and async worker processing

                        │- **Cost Optimization**: On-demand infrastructure with automated teardown (~$0.21/hour, deployable with $120 credits)

                        ▼- **Type-Safe Full Stack**: End-to-end TypeScript implementation across all services

                 ┌──────────────┐- **Observability**: Structured logging, health checks, and resource monitoring

                 │   MongoDB    │

                 │    Atlas     │## 🏗️ Architecture & Design Decisions

                 └──────────────┘

### Application Architecture

┌─────────────────────────────────────────────────────────────┐

│                    AWS Infrastructure                        │Implemented a **microservices pattern** with three decoupled services communicating through HTTP APIs:

│                                                              │

│  ┌──────────────────────────────────────────────────┐      │```

│  │              EKS Cluster (K8s 1.33)              │      │┌──────────────────────────────────────────────────┐

│  │                                                   │      ││            AWS Application Load Balancer          │

│  │   Multi-AZ Node Group (2x t3.small)             │      ││          (Path-based routing to services)         │

│  │   ├─ us-east-2a: Worker Node                    │      │└───────────┬──────────────────────────────────────┘

│  │   └─ us-east-2b: Worker Node                    │      │            │

│  └──────────────────────────────────────────────────┘      │    ┌───────┼────────┐

│                                                              │    │       │        │

│  ┌─────────────┐  ┌─────────────┐  ┌──────────────┐       │    ▼       ▼        ▼

│  │     ECR     │  │     VPC     │  │  NAT Gateway │       │┌─────┐ ┌─────┐ ┌─────┐

│  │  Registries │  │  10.0.0.0/16│  │              │       ││Front│ │Back │ │Work │      ┌──────────┐

│  └─────────────┘  └─────────────┘  └──────────────┘       ││ end │─│ end │─│ er  │      │ MongoDB  │

└─────────────────────────────────────────────────────────────┘│Next │ │Nest │ │Expr │─────▶│  Atlas   │

```│ JS  │ │ JS  │ │ ess │      │ (Cloud)  │

└─────┘ └─────┘ └─────┘      └──────────┘

**Key Design Decisions:**```

- **Kubernetes 1.33** - Latest stable version with standard support (saves $22.30/deploy vs 1.31 extended support)

- **Multi-AZ deployment** - High availability across 2 availability zones**Key Architectural Decisions:**

- **Private node placement** - Enhanced security with NAT gateway for egress

- **External MongoDB** - Simplifies cluster lifecycle management for demos- **Frontend**: Next.js 14 with API rewrites for seamless backend communication

- **Backend**: NestJS for structured, scalable API with TypeScript decorators

---- **Worker**: Separate Express service for async tasks (decoupled for horizontal scaling)

- **Database**: External MongoDB Atlas (avoids managing database in cluster)

## 🚀 Quick Start

### AWS Infrastructure Design

### Prerequisites

- AWS Account with CLI configured (`aws configure`)Designed a **production-ready, multi-AZ Kubernetes environment** on AWS:

- Terraform ≥ 1.5

- kubectl, Docker Desktop```

- MongoDB Atlas account (free tier)AWS Cloud (us-east-2 - Ohio)

│

### Deploy Complete Infrastructure (~12 minutes)├── VPC (10.0.0.0/16)

│   ├── Public Subnets (10.0.1.0/24, 10.0.2.0/24)

```bash│   │   ├── Internet Gateway

# 1. Clone repository│   │   └── NAT Gateway (for private subnet internet access)

git clone https://github.com/Dicante/PureHouse.git│   │

cd PureHouse│   └── Private Subnets (10.0.10.0/24, 10.0.20.0/24)

│       └── EKS Worker Nodes (isolated from internet)

# 2. One-time AWS setup (creates S3, DynamoDB, OIDC, IAM roles)│

./scripts/setup-aws.sh├── EKS Cluster (Kubernetes 1.31)

│   ├── Managed Control Plane (AWS handles HA)

# 3. Configure MongoDB connection│   ├── Node Group (2x t3.small, multi-AZ)

cd terraform/environments/production│   ├── IRSA (IAM Roles for Service Accounts)

cp terraform.tfvars.example terraform.tfvars│   └── ALB Ingress Controller

# Edit terraform.tfvars - add your MongoDB URI│

├── ECR (Private Docker registries)

# 4. Deploy everything (Terraform + Docker + Kubernetes)│   ├── purehouse-production-frontend

cd ../../..│   ├── purehouse-production-backend

./scripts/deploy.sh│   └── purehouse-production-worker

# Follow prompts: yes → 1 (skip build) → yes│

└── IAM & Security

# ✅ Application will be live at the ALB URL shown    ├── OIDC Provider (GitHub Actions authentication)

```    ├── Cluster IAM Role

    ├── Node Group IAM Role

### Destroy Infrastructure (~7 minutes)    └── ALB Controller IAM Role

```

```bash

./scripts/destroy.sh**Infrastructure Highlights:**

# Select option 1: Destroys expensive resources, keeps VPC/ECR

# Cost: $153/month → $0.01/month- **Multi-AZ for HA**: Resources spread across 2 availability zones

```- **Private worker nodes**: Enhanced security with NAT gateway for outbound only

- **OIDC authentication**: No AWS credentials stored in GitHub (modern security)

### Check Status Anytime- **Modular Terraform**: Reusable modules (VPC, EKS, ECR, Kubernetes)

- **State locking**: S3 + DynamoDB prevents concurrent modification issues

```bash

./scripts/status.sh## 📁 Project Structure

# Shows: Cluster status, pods, services, ALB URL, cost estimate

``````

PureHouse/

---├── .github/workflows/          # CI/CD Automation

│   ├── ci.yml                  # Test & validate on PRs

## 💰 Cost Optimization Success Story│   └── cd.yml                  # Build & deploy on main push

│

**The Challenge:** Initial infrastructure cost $33.84 per deploy, burning through AWS Educate credits rapidly.├── docs/

│   └── DEVOPS.md               # DevOps architecture showcase

**Root Cause Analysis:**│

- Discovered EKS Extended Support was charging $0.50/hr (vs $0.10/hr standard support)├── kubernetes/                 # K8s manifests (GitOps-ready)

- Kubernetes 1.31 was already near end-of-support (Nov 25, 2025)│   ├── backend/deployment.yaml

- Extended Support = 66% of total infrastructure cost│   ├── frontend/deployment.yaml

│   ├── worker/deployment.yaml

**Solution Implemented:**│   └── ingress/ingress.yaml    # ALB routing configuration

- Changed Kubernetes version from 1.31 → 1.33│

- 1.33 has standard support until July 2026├── terraform/                  # Complete IaC implementation

- No code changes required, just Terraform variable update│   ├── modules/

│   │   ├── vpc/                # Network infrastructure

**Results:**│   │   ├── eks/                # Kubernetes cluster

```│   │   ├── ecr/                # Container registries

Before: $33.84/deploy  (EKS Extended Support $22.30)│   │   └── kubernetes/         # K8s resources & ALB controller

After:  $11.54/deploy  (EKS Standard $6.00)│   ├── environments/

Savings: 66% cost reduction│   │   └── production/         # Production environment

```│   └── state-setup/            # Terraform backend setup

│

**Impact on AWS Credits:**├── scripts/                    # Production-ready automation

- $85 remaining credits│   ├── setup-aws.sh            # One-time: S3, DynamoDB, OIDC, IAM roles

- Before: ~2.5 deploys possible│   ├── deploy.sh               # Full deployment with auto-retry logic

- After: ~7-8 full deploys possible│   ├── destroy.sh              # Smart destroy (2 modes with pre-cleanup)

- **3× more demonstration opportunities**│   └── status.sh               # Real-time infrastructure status & costs

│

*This demonstrates real-world cost engineering - identifying billing anomalies, researching root causes, and implementing architectural fixes.*├── purehouse-frontend/         # Next.js SSR application

├── purehouse-backend/          # NestJS REST API

---└── purehouse-worker/           # Async processing service

```

## 🔧 Automation Highlights

## �️ Technical Implementation

### deploy.sh - Zero-Touch Deployment

```bash### DevOps & Infrastructure

✅ Automatic retry logic for EKS aws-auth ConfigMap timing issues

✅ Three Docker build strategies (skip/standard/multi-arch)**Terraform Modules** (Reusable, Environment-Agnostic)

✅ Terraform with auto-planning and state locking

✅ kubectl auto-configuration and health checks- `vpc`: Creates network with public/private subnets, NAT, IGW

✅ Automatic ALB URL extraction and display- `eks`: Provisions managed Kubernetes with node groups and IRSA

```- `ecr`: Sets up private Docker registries with lifecycle policies

- `kubernetes`: Deploys ALB controller, secrets, and namespaces

### destroy.sh - Smart Teardown

```bash**CI/CD Pipeline** (GitHub Actions with OIDC)

✅ Pre-cleanup of Kubernetes resources (prevents hanging)

✅ Two modes: cost-saving ($153→$0.01/mo) vs complete cleanup```yaml

✅ Fallback to AWS CLI if Terraform times out# Secure authentication without stored credentials

✅ Automatic state cleanup for manually-deleted resourcesCI: Test → Lint → Build validation

✅ 100% success rate, 7-minute executionCD: Build images → Push to ECR → Deploy to EKS

``````



### status.sh - Real-Time Monitoring**Kubernetes Configuration**

```bash

✅ Live cluster and pod status- 2 replicas for frontend/backend (high availability)

✅ Service health checks- Resource limits prevent pod resource exhaustion

✅ Cost estimation with real-time calculations- Rolling updates with health checks (zero downtime)

✅ Application URL for quick access- ClusterIP services with Ingress-based routing

```

### Application Stack

---

**Frontend** - Next.js 14 (React)

## 🎓 Real Production Challenges Solved

- Server-side rendering for SEO

| Challenge | Solution | Impact |- API routes with rewrites (proxy pattern)

|-----------|----------|--------|- TypeScript for type safety

| **EKS aws-auth timing** | Automatic retry with 10s delay & re-planning | 100% automated deploys |- Tailwind CSS for styling

| **Ingress cleanup blocking destroy** | Pre-cleanup script removes ALB/TargetGroups first | Destroy completes in 7min reliably |

| **Terraform state locks** | Auto-detect and release stuck locks | Zero manual intervention |**Backend** - NestJS (Node.js)

| **Cost overrun** | Kubernetes version change (1.31→1.33) | 66% cost reduction |

| **Image rebuild time** | Two-tier destroy (keep ECR images) | Redeploy in 10min vs 25min |- RESTful API with decorators

- MongoDB integration with Mongoose

---- Health checks at `/api/health`

- Worker HTTP client for async tasks

## 📊 Project Metrics

**Worker** - Express.js

| Metric | Value |

|--------|-------|- Lightweight processing service

| **Infrastructure** | AWS EKS Kubernetes 1.33, Multi-AZ VPC |- Colorized logging for visibility

| **Deployment Time** | 12 minutes (first deploy), 10 minutes (redeploy) |- Health endpoint for K8s probes

| **Destroy Time** | 7 minutes (cost-saving mode) |- Async event handling

| **Cost Per Deploy** | $11.54 (optimized from $33.84) |

| **Automation Level** | 100% - Zero manual steps |### Cost Optimization Strategy

| **Lines of IaC** | ~1,200 lines of Terraform across 4 modules |

| **Services Deployed** | 3 microservices (Frontend, Backend, Worker) |Implemented **on-demand infrastructure** approach for maximum demo time with limited credits:



---**Full Deployment Costs:**

- EKS Control Plane: $73/month ($0.10/hour)

## 📁 Project Structure- EC2 Nodes (2x t3.small): ~$30/month ($0.042/hour)  

- Application Load Balancer: ~$18/month ($0.025/hour)

```- NAT Gateway: ~$32/month ($0.045/hour)

PureHouse/- **Total: ~$153/month or $0.21/hour**

├── terraform/                    # Infrastructure as Code

│   ├── modules/**Cost-Saving Mode (After Destroy Option 1):**

│   │   ├── vpc/                 # Multi-AZ networking- VPC components: $0.00/month

│   │   ├── eks/                 # Kubernetes cluster- ECR image storage: ~$0.01/month

│   │   ├── ecr/                 # Container registries- S3 Terraform state: ~$0.00/month

│   │   └── kubernetes/          # K8s resources + ALB controller- **Total: ~$0.01/month**

│   └── environments/

│       └── production/          # Production configuration**Demo Time Calculation:**

│- With $100 AWS credits

├── .github/workflows/           # CI/CD Automation- Full deployment: ~476 hours (19.8 days continuous)

│   ├── ci.yml                   # Tests on pull requests- **Or:** 1 hour/day for 476 days (15.8 months!)

│   └── cd.yml                   # Deploy on main push (OIDC auth)- **Or:** 8 hours/day for 59.5 days (2 months of work weeks)

│

├── kubernetes/                  # K8s Manifests**Automated workflow enables**:

│   ├── backend/deployment.yaml- Destroy after each demo/interview (7 minutes)

│   ├── frontend/deployment.yaml- Redeploy before next demo (10 minutes)

│   ├── worker/deployment.yaml- Maximum cost efficiency with minimal downtime

│   └── ingress/ingress.yaml

│## � Key Learnings & Challenges

├── scripts/                     # Production-ready automation

│   ├── setup-aws.sh            # Bootstrap AWS resources## 🎓 Key Learnings & Production Challenges Solved

│   ├── deploy.sh               # Full deployment with retry logic

│   ├── destroy.sh              # Smart teardown (2 modes)### Real-World Infrastructure Challenges

│   └── status.sh               # Infrastructure monitoring

│1. **EKS aws-auth ConfigMap Timing Issue**

├── docs/   - **Problem**: Terraform tries to update `aws-auth` before EKS creates it

│   └── TECHNICAL.md            # Deep technical documentation   - **Solution**: Implemented automatic retry logic with 10s delay and re-planning

│   - **Impact**: Deploy script now 100% automated, no manual intervention needed

├── purehouse-frontend/         # Next.js SSR application

├── purehouse-backend/          # NestJS REST API2. **Kubernetes Resource Cleanup Blocking Destroy**

└── purehouse-worker/           # Express async processor   - **Problem**: Ingress and TargetGroupBindings with finalizers blocked namespace deletion

```   - **Solution**: Pre-cleanup script removes Ingress, ALB, Target Groups before Terraform destroy

   - **Impact**: Destroy process completes successfully in ~7 minutes without hanging

---

3. **Terraform State Locks from Canceled Operations**

## 📖 Documentation   - **Problem**: Ctrl+C during apply left DynamoDB locks, blocking future operations

   - **Solution**: Scripts detect and auto-release stuck locks before operations

**For recruiters:** This README provides a high-level overview of skills and architecture.   - **Impact**: No more manual `terraform force-unlock` commands needed



**For technical deep-dive:** See [docs/TECHNICAL.md](docs/TECHNICAL.md) for:4. **EKS Cluster Deletion Timing**

- Complete infrastructure architecture diagrams   - **Problem**: AWS takes 2-5 minutes to delete cluster, blocking redeploy

- Terraform module design patterns   - **Solution**: Destroy script uses `aws eks wait cluster-deleted` for automatic waiting

- CI/CD pipeline implementation details   - **Impact**: Reliable destroy → redeploy cycles without manual checks

- Automation script documentation

- Troubleshooting guides5. **Cost Optimization Without Losing Images**

- Security best practices   - **Problem**: Full destroy meant rebuilding/pushing images (~10 min + Docker build time)

   - **Solution**: Two-tier destroy strategy (expensive-only vs everything)

---   - **Impact**: Redeploy from $0.01/month to full stack in 10 min using existing images



## 🔗 Live Demo & Contact### DevOps Skills Demonstrated



**GitHub Repository:** [github.com/Dicante/PureHouse](https://github.com/Dicante/PureHouse)- ✅ **Cloud Architecture**: Complete AWS multi-AZ infrastructure from scratch

- ✅ **Infrastructure as Code**: Modular Terraform with proper state management

**Portfolio Website:** *Coming soon*- ✅ **Kubernetes Production Patterns**: EKS, IRSA, ALB Ingress, proper resource cleanup

- ✅ **Automation & Scripting**: Robust bash scripts with error handling and retries

**Live Demo:** *Available on-demand* - Infrastructure deployed for interviews/demos and destroyed after to manage costs.- ✅ **CI/CD Ready**: OIDC authentication, no stored credentials

- ✅ **Problem Solving**: Debugged and fixed real timing/race conditions

---- ✅ **Cost Engineering**: On-demand infrastructure pattern for demos

- ✅ **Full-Stack Development**: TypeScript across Next.js, NestJS, Express

## 👤 About Me

## 🔧 Automated Scripts Deep Dive

**Julian Dicante**  

*Aspiring DevOps Engineer | Cloud Infrastructure | Kubernetes*All scripts are **production-ready** with comprehensive error handling, retry logic, and user feedback.



I built this project to demonstrate my ability to design, implement, and operate production-grade cloud infrastructure. Every component - from the Terraform modules to the automation scripts - was built from scratch to solve real infrastructure challenges.### `deploy.sh` - Intelligent Deployment



**What I bring to a DevOps team:****Features:**

- Deep understanding of AWS services and cost optimization- ✅ Pre-flight checks (AWS credentials, MongoDB config)

- Strong automation mindset with production-ready scripting- ✅ Three build options: skip (existing images), standard, multi-arch buildx

- Kubernetes operational experience (EKS, deployments, troubleshooting)- ✅ **Automatic retry** for EKS aws-auth ConfigMap timing (max 3 attempts)

- Infrastructure as Code expertise (Terraform modular design)- ✅ Terraform plan → apply with state locking

- Problem-solving skills proven through real challenges- ✅ Auto-configure kubectl and deploy K8s manifests

- Full-stack development background (TypeScript, Node.js, React)- ✅ Wait for deployments with rollout status

- ✅ Fetch and display ALB URL automatically

📧 **Email:** juliandicante@outlook.com  

💼 **LinkedIn:** [linkedin.com/in/julian-dicante](https://linkedin.com/in/julian-dicante)  **Usage:**

🐙 **GitHub:** [github.com/Dicante](https://github.com/Dicante)```bash

./scripts/deploy.sh

---# Interactive prompts guide you through:

# 1. MongoDB config confirmation

## 📜 License# 2. Build strategy selection

# 3. Cost warning acceptance

MIT License - This is a portfolio project demonstrating DevOps skills.# Auto-completes in ~12 minutes

```

---

### `destroy.sh` - Safe Infrastructure Teardown

<div align="center">

**Features:**

**⭐ If you're a recruiter and this project demonstrates the skills you're looking for, I'd love to discuss how I can contribute to your team! ⭐**- ✅ **Pre-cleanup phase**: Removes Ingress, ALB, TargetGroupBindings before Terraform

- ✅ Two destruction modes:

</div>  - **Mode 1** (Cost-Saving): Destroys EKS, nodes, ALB, NAT (~7 min, keeps VPC/ECR)

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
