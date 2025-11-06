# PureHouse 🏠

> Full-stack blog application showcasing production-grade DevOps implementation on AWS

[![TypeScript](https://img.shields.io/badge/TypeScript-5.0-blue)](https://www.typescriptlang.org/)
[![Next.js](https://img.shields.io/badge/Next.js-14-black)](https://nextjs.org/)
[![NestJS](https://img.shields.io/badge/NestJS-10-red)](https://nestjs.com/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.28-326CE5)](https://kubernetes.io/)
[![Terraform](https://img.shields.io/badge/Terraform-1.5+-7B42BC)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-EKS-FF9900)](https://aws.amazon.com/eks/)

## 📖 Project Overview

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
├── EKS Cluster (Kubernetes 1.28)
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
├── scripts/                    # Automation scripts
│   ├── setup-aws.sh            # Initial AWS configuration
│   ├── deploy.sh               # Full deployment automation
│   ├── destroy.sh              # Infrastructure teardown
│   └── status.sh               # Deployment status check
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

Implemented **on-demand infrastructure** approach:
- Total cost: ~$151/month or ~$0.21/hour
- With $120 AWS credits = ~600 hours of demo time
- Automated scripts for quick deploy/destroy
- No idle costs when infrastructure is down

## � Key Learnings & Challenges

### Technical Challenges Solved

1. **Zero-Downtime Deployments**: Implemented rolling updates with proper health checks
2. **Secure Secrets Management**: Used Kubernetes secrets with external MongoDB Atlas
3. **OIDC Authentication**: Eliminated need for stored AWS credentials in CI/CD
4. **Multi-AZ Networking**: Designed resilient network with NAT gateway for private subnets
5. **Cost Optimization**: Architected on-demand infrastructure with automated teardown

### Skills Demonstrated

- ✅ **Cloud Architecture**: Designed complete AWS infrastructure from scratch
- ✅ **Infrastructure as Code**: Terraform with modular, reusable patterns
- ✅ **Kubernetes**: EKS cluster management, deployments, services, ingress
- ✅ **CI/CD**: GitHub Actions with modern OIDC authentication
- ✅ **Containerization**: Multi-stage Docker builds for all services
- ✅ **Full-Stack Development**: TypeScript across Next.js, NestJS, Express
- ✅ **DevOps Automation**: Bash scripts for deployment orchestration
- ✅ **Security**: IAM roles, IRSA, private subnets, secrets management

## � Documentation

- **[DevOps Architecture](docs/DEVOPS.md)** - Deep dive into infrastructure decisions
- **[CI/CD Workflows](.github/workflows/README.md)** - Pipeline implementation details

## 🔗 Project Links

- **Live Demo**: *[Currently deployed on-demand for demos]*
- **Repository**: [github.com/YOUR_USERNAME/PureHouse](https://github.com/YOUR_USERNAME/PureHouse)

## 👤 Author

**Your Name**

DevOps Engineer | Cloud Architecture | Kubernetes

- 🔗 LinkedIn: [linkedin.com/in/your-profile](https://linkedin.com/in/your-profile)
- 💼 Portfolio: [your-portfolio.com](https://your-portfolio.com)
- 📧 Email: your.email@example.com

---

*This project was built as a portfolio piece to demonstrate production-grade DevOps implementation. It showcases my ability to design, implement, and deploy cloud-native applications using modern infrastructure practices.*
