# PureHouse - Production DevOps Portfolio 🚀

> **Full-stack blog application demonstrating enterprise-grade DevOps skills on AWS**

[![AWS EKS](https://img.shields.io/badge/AWS-EKS_1.33-FF9900?logo=amazon-aws&logoColor=white)](https://aws.amazon.com/eks/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.33-326CE5?logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![TypeScript](https://img.shields.io/badge/TypeScript-Full_Stack-3178C6?logo=typescript&logoColor=white)](https://www.typescriptlang.org/)
[![CI/CD](https://img.shields.io/badge/CI/CD-GitHub_Actions-2088FF?logo=github-actions&logoColor=white)](https://github.com/features/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Security](https://img.shields.io/badge/Security-OIDC-green.svg)](SECURITY.md)

---

## 🎯 Why This Project Stands Out

**Built to demonstrate real-world DevOps engineering skills**, not just tutorials. This project showcases:

✅ **Complete AWS infrastructure** designed from scratch using Terraform
✅ **Production-ready Kubernetes** on EKS with multi-AZ high availability
✅ **Automated CI/CD pipeline** with modern OIDC authentication (zero stored credentials)
✅ **Cost optimization** - Reduced infrastructure costs by 66% through architecture decisions
✅ **100% automation** - Deploy and destroy complete infrastructure with single commands
✅ **Real problem-solving** - Overcame production challenges like EKS timing issues and resource cleanup

---

## 💼 DevOps Skills Demonstrated

<table>
<tr>
<td width="50%">

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                          Internet                           │
└─────────────────────────────┬───────────────────────────────┘
                              │
                              ▼
                 ┌────────────────────────┐
                 │    Application LB      │
                 │  (Path-based routing)  │
                 └────────────┬───────────┘
                              │
             ┌────────────────┼────────────────┐
             │                │                │
             ▼                ▼                ▼
        ┌─────────┐      ┌─────────┐      ┌─────────┐
        │Frontend │      │ Backend │      │ Worker  │
        │ Next.js │─────▶│  NestJS │◀─────│ Express │
        │         │      │         │      │         │
        └─────────┘      └────┬────┘      └─────────┘
                              │
                              ▼
                      ┌───────────────┐
                      │    MongoDB    │
                      │     Atlas     │
                      └───────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    AWS Infrastructure                       │
│                                                             │
│    ┌──────────────────────────────────────────────────┐     │
│    │              EKS Cluster (K8s 1.33)              │     │
│    │                                                  │     │
│    │        Multi-AZ Node Group (2x t3.small)         │     │
│    │         ├─ us-east-2a: Worker Node               │     │
│    │         └─ us-east-2b: Worker Node               │     │
│    └──────────────────────────────────────────────────┘     │
│                                                             │
│    ┌─────────────┐   ┌─────────────┐   ┌──────────────┐     │
│    │     ECR     │   │     VPC     │   │  NAT Gateway │     │
│    │  Registries │   │  10.0.0.0/16│   │              │     │
│    └─────────────┘   └─────────────┘   └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

**Key Design Decisions:**

- **Kubernetes 1.33** - Latest stable version with standard support (saves $22.30/deploy vs 1.31 extended support)
- **Multi-AZ deployment** - High availability across 2 availability zones
- **Private node placement** - Enhanced security with NAT gateway for egress
- **External MongoDB** - Simplifies cluster lifecycle management for demos

---

## 🚀 Quick Start

### Prerequisites

- AWS Account with CLI configured (`aws configure`)
- Terraform ≥ 1.5
- kubectl, Docker Desktop
- MongoDB Atlas account (free tier)

### Deploy Complete Infrastructure (~12 minutes)

```bash
# 1. Clone repository
git clone https://github.com/Dicante/PureHouse.git
cd PureHouse

# 2. One-time AWS setup (creates S3, DynamoDB, OIDC, IAM roles)
./scripts/setup-aws.sh

# 3. Configure MongoDB connection
cd terraform/environments/production
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars - add your MongoDB URI

# 4. Deploy everything (Terraform + Docker + Kubernetes)
cd ../../..
./scripts/deploy.sh
# Follow prompts: yes → 1 (skip build) → yes

# ✅ Application will be live at the ALB URL shown
```

### Destroy Infrastructure (~7 minutes)

```bash
./scripts/destroy.sh
# Select option 1: Destroys expensive resources, keeps VPC/ECR
# Cost: $153/month → $0.01/month
```

### Check Status Anytime

```bash
./scripts/status.sh
# Shows: Cluster status, pods, services, ALB URL, cost estimate
```

---

## 💰 Cost Optimization Success Story

**The Challenge:** Initial infrastructure cost $33.84 per deploy, burning through AWS Educate credits rapidly.

**Root Cause Analysis:**

- Discovered EKS Extended Support was charging $0.50/hr (vs $0.10/hr standard support)
- Kubernetes 1.31 was already near end-of-support (Nov 25, 2025)
- Extended Support = 66% of total infrastructure cost

**Solution Implemented:**

- Changed Kubernetes version from 1.31 → 1.33
- 1.33 has standard support until July 2026
- No code changes required, just Terraform variable update

**Results:**

```
Before: $33.84/deploy  (EKS Extended Support $22.30)
After:  $11.54/deploy  (EKS Standard $6.00)
Savings: 66% cost reduction
```

**Impact on AWS Credits:**

- $85 remaining credits
- Before: ~2.5 deploys possible
- After: ~7-8 full deploys possible
- **3× more demonstration opportunities**

*This demonstrates real-world cost engineering - identifying billing anomalies, researching root causes, and implementing architectural fixes.*

---

## 🔧 Automation Highlights

### deploy.sh - Zero-Touch Deployment

```bash
✅ Automatic retry logic for EKS aws-auth ConfigMap timing issues
✅ Three Docker build strategies (skip/standard/multi-arch)
✅ Terraform with auto-planning and state locking
✅ kubectl auto-configuration and health checks
✅ Automatic ALB URL extraction and display
```

### destroy.sh - Smart Teardown

```bash
✅ Pre-cleanup of Kubernetes resources (prevents hanging)
✅ Two modes: cost-saving ($153→$0.01/mo) vs complete cleanup
✅ Fallback to AWS CLI if Terraform times out
✅ Automatic state cleanup for manually-deleted resources
✅ 100% success rate, 7-minute execution
```

### status.sh - Real-Time Monitoring

```bash
✅ Live cluster and pod status
✅ Service health checks
✅ Cost estimation with real-time calculations
✅ Application URL for quick access
```

---

## 🎓 Real Production Challenges Solved

| Challenge                                  | Solution                                          | Impact                             |
| ------------------------------------------ | ------------------------------------------------- | ---------------------------------- |
| **EKS aws-auth timing**              | Automatic retry with 10s delay & re-planning      | 100% automated deploys             |
| **Ingress cleanup blocking destroy** | Pre-cleanup script removes ALB/TargetGroups first | Destroy completes in 7min reliably |
| **Terraform state locks**            | Auto-detect and release stuck locks               | Zero manual intervention           |
| **Cost overrun**                     | Kubernetes version change (1.31→1.33)            | 66% cost reduction                 |
| **Image rebuild time**               | Two-tier destroy (keep ECR images)                | Redeploy in 10min vs 25min         |

---

## 📊 Project Metrics

| Metric                      | Value                                            |
| --------------------------- | ------------------------------------------------ |
| **Infrastructure**    | AWS EKS Kubernetes 1.33, Multi-AZ VPC            |
| **Deployment Time**   | 12 minutes (first deploy), 10 minutes (redeploy) |
| **Destroy Time**      | 7 minutes (cost-saving mode)                     |
| **Cost Per Deploy**   | $11.54 (optimized from $33.84)                   |
| **Automation Level**  | 100% - Zero manual steps                         |
| **Lines of IaC**      | ~1,200 lines of Terraform across 4 modules       |
| **Services Deployed** | 3 microservices (Frontend, Backend, Worker)      |

---

## 📁 Project Structure

```
PureHouse/
│
├── terraform/                  # Infrastructure as Code
│   ├── modules/
│   │   ├── vpc/                # Multi-AZ networking
│   │   ├── eks/                # Kubernetes cluster
│   │   ├── ecr/                # Container registries
│   │   └── kubernetes/         # K8s resources + ALB controller
│   │
│   └── environments/
│       └── production/         # Production configuration
│
├── .github/workflows/          # CI/CD Automation
│   ├── ci.yml                  # Tests on pull requests
│   └── cd.yml                  # Deploy on main push (OIDC auth)
│
├── kubernetes/                 # K8s Manifests
│   ├── backend/deployment.yaml
│   ├── frontend/deployment.yaml
│   ├── worker/deployment.yaml
│   └── ingress/ingress.yaml
│
├── scripts/                    # Production-ready automation
│   ├── setup-aws.sh            # Bootstrap AWS resources
│   ├── deploy.sh               # Full deployment with retry logic
│   ├── destroy.sh              # Smart teardown (2 modes)
│   └── status.sh               # Infrastructure monitoring
│
├── docs/
│   └── TECHNICAL.md            # Deep technical documentation
│
├── purehouse-frontend/         # Next.js SSR application
├── purehouse-backend/          # NestJS REST API
└── purehouse-worker/           # Express async processor
```

---

## 📖 Documentation

**For recruiters:** This README provides a high-level overview of skills and architecture.

**For technical deep-dive:** See [docs/TECHNICAL.md](docs/TECHNICAL.md) for:

- Complete infrastructure architecture diagrams
- Terraform module design patterns
- CI/CD pipeline implementation details
- Automation script documentation
- Troubleshooting guides
- Security best practices

---

## 🔗 Live Demo & Contact

**GitHub Repository:** [github.com/Dicante/PureHouse](https://github.com/Dicante/PureHouse)

**Live Demo:** *Available on-demand* - Infrastructure deployed for interviews/demos and destroyed after to manage costs.

---

## 👤 About Me

**Julian Dicante**
*Aspiring DevOps Engineer | Cloud Infrastructure | Kubernetes*

I built this project to demonstrate my ability to design, implement, and operate production-grade cloud infrastructure. Every component - from the Terraform modules to the automation scripts - was built from scratch to solve real infrastructure challenges.

**What I bring to a DevOps team:**

- Deep understanding of AWS services and cost optimization
- Strong automation mindset with production-ready scripting
- Kubernetes operational experience (EKS, deployments, troubleshooting)
- Infrastructure as Code expertise (Terraform modular design)
- Problem-solving skills proven through real challenges
- Full-stack development background (TypeScript, Node.js, React)

📧 **Email:** juliandicante@outlook.com
💼 **LinkedIn:** [linkedin.com/in/julian-dicante](https://linkedin.com/in/julian-dicante)
🐙 **GitHub:** [github.com/Dicante](https://github.com/Dicante)

---

## 📜 License

MIT License - See [LICENSE](LICENSE) file for details.

**This is a portfolio project demonstrating DevOps engineering skills.**

While the code is open source for learning purposes, the architecture design, automation strategies, and infrastructure patterns represent significant personal work. If you use this project as inspiration or reference, please provide attribution.

---
