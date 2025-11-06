# DevOps Architecture Showcase

> Documentation of architectural decisions, infrastructure design, and DevOps implementation for PureHouse

## 📋 Overview

This document showcases the **DevOps engineering decisions** and **cloud architecture design** implemented in the PureHouse project. It demonstrates my expertise in designing production-grade infrastructure using modern cloud-native practices.

## 🎯 Project Goals & Design Constraints

### Business Requirements
- **Cost Efficiency**: On-demand deployment strategy (~$0.21/hour with automated teardown)
- **High Availability**: Multi-AZ deployment for resilience
- **Security**: No credentials in code, OIDC-based CI/CD
- **Automation**: Complete infrastructure as code with CI/CD

### Technical Decisions Made

| Decision | Alternative Considered | Reasoning |
|----------|----------------------|-----------|
| **EKS over EC2** | Self-managed K8s on EC2 | Managed control plane reduces operational overhead, scales automatically |
| **MongoDB Atlas** | Self-hosted in cluster | External DB simplifies cluster destroy/recreation, better for demos |
| **Terraform** | CloudFormation, Pulumi | Industry standard IaC, multi-cloud transferable skills |
| **GitHub Actions** | Jenkins, GitLab CI | Native GitHub integration, free for public repos, OIDC support |
| **OIDC Auth** | Access key storage | Modern security best practice, eliminates credential rotation |
| **Public Node Placement** | Private with NAT | Cost optimization for demo project (saves $32/month on NAT) |
| **t3.small nodes** | t3.medium | Adequate for demo workload, 50% cost savings |
| **ALB Ingress** | NGINX Ingress | Native AWS integration, easier SSL/certificate management |

## 🏗️ Infrastructure Architecture

### VPC Network Design

Implemented a **multi-AZ VPC** with public/private subnet architecture:

```
AWS Region: us-east-2 (Ohio)
VPC CIDR: 10.0.0.0/16

┌─────────────────────────────────────────────────────┐
│                       VPC                            │
│                                                      │
│  AZ: us-east-2a             AZ: us-east-2b          │
│  ┌────────────────┐         ┌────────────────┐     │
│  │ Public Subnet  │         │ Public Subnet  │     │
│  │ 10.0.1.0/24    │         │ 10.0.2.0/24    │     │
│  │                │         │                │     │
│  │ - IGW Access   │         │ - IGW Access   │     │
│  │ - EKS Nodes    │         │ - EKS Nodes    │     │
│  │ - ALB (HA)     │         │ - ALB (HA)     │     │
│  └────────────────┘         └────────────────┘     │
│                                                      │
│  ┌────────────────┐         ┌────────────────┐     │
│  │ Private Subnet │         │ Private Subnet │     │
│  │ 10.0.10.0/24   │         │ 10.0.20.0/24   │     │
│  │ (Reserved)     │         │ (Reserved)     │     │
│  └────────────────┘         └────────────────┘     │
└─────────────────────────────────────────────────────┘
```

**Design Rationale:**
- **Multi-AZ deployment**: Survives single AZ failures
- **Public node placement**: Cost-optimized for demo workload
- **Private subnets reserved**: Future expansion for sensitive workloads (databases, workers)
- **Single NAT Gateway**: Adequate for demo scale, saves $32/month

### EKS Cluster Architecture

```
┌──────────────────────────────────────────┐
│         EKS Control Plane                 │
│     (AWS Managed - Multi-AZ HA)          │
└──────────────────┬───────────────────────┘
                   │
        ┌──────────┴──────────┐
        │                     │
   ┌────▼─────┐         ┌────▼─────┐
   │  Node 1  │         │  Node 2  │
   │ t3.small │         │ t3.small │
   │ AZ: 2a   │         │ AZ: 2b   │
   └──────────┘         └──────────┘
```

**Configuration:**
- **Kubernetes Version**: 1.28
- **Node Type**: t3.small (2 vCPU, 2GB RAM)
- **Scaling**: Min 2, Desired 2, Max 3
- **AMI**: Amazon Linux 2 EKS-optimized
- **Disk**: 20GB gp3

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
│   └── app-config
└── Secrets
    └── app-secrets (MongoDB URI)
```

**Resource Allocation Strategy:**

| Service | Replicas | CPU Request | Memory Request | Reasoning |
|---------|----------|-------------|----------------|-----------|
| Frontend | 2 | 100m | 128Mi | High traffic, needs HA |
| Backend | 2 | 100m | 256Mi | Stateless API, horizontal scaling |
| Worker | 1 | 50m | 128Mi | Async tasks, not user-facing |

**Health Check Implementation:**
- **Liveness probes**: Detect and restart crashed containers
- **Readiness probes**: Control traffic routing during deployments
- **Startup probes**: Handle slow application startup

## 🔄 CI/CD Pipeline Architecture

### GitHub Actions Workflow Design

Implemented **two-stage pipeline** with OIDC authentication:

```
┌─────────────┐
│ Git Push to │
│    main     │
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│  CI Workflow    │
│                 │
│ 1. Lint code    │
│ 2. Run tests    │
│ 3. Validate     │
│    builds       │
└──────┬──────────┘
       │
       ▼
┌─────────────────┐
│  CD Workflow    │
│                 │
│ 1. Auth via     │
│    OIDC         │
│ 2. Build images │
│ 3. Push to ECR  │
│ 4. Deploy to    │
│    EKS          │
└─────────────────┘
```

### OIDC Authentication Flow

**Traditional Approach** (What I avoided):
```
GitHub Secrets → AWS Access Keys → Security risk
```

**OIDC Approach** (What I implemented):
```
GitHub OIDC Token → AWS STS → Temporary credentials → No stored secrets
```

**Benefits:**
- ✅ No long-lived credentials in GitHub
- ✅ Automatic credential rotation
- ✅ Follows AWS security best practices
- ✅ Audit trail via CloudTrail

### Continuous Integration (CI)

**Trigger**: Pull requests to `main`

```yaml
Jobs:
  - test-backend: Run NestJS unit & e2e tests
  - test-frontend: Build validation
  - test-worker: Runtime validation
  - validate-terraform: terraform fmt & validate
```

### Continuous Deployment (CD)

**Trigger**: Push to `main` branch

```yaml
Jobs:
  1. Authenticate with AWS via OIDC
  2. Build Docker images (multi-stage builds)
  3. Tag with git SHA and 'latest'
  4. Push to ECR repositories
  5. Update kubeconfig
  6. Apply Kubernetes manifests
  7. Wait for rollout completion
```

**Deployment Strategy**: Rolling update with maxUnavailable: 1, maxSurge: 1

## 🔐 Security Implementation

### Secrets Management

**Kubernetes Secrets** for sensitive data:
- MongoDB connection string
- API keys (if any)
- Service-to-service tokens

**GitHub Secrets** for CI/CD:
- `AWS_ACCOUNT_ID`
- `MONGODB_URI`

**No secrets in code**: All sensitive data externalized

### IAM Role Design

**Principle of Least Privilege** applied:

```
GitHub Actions Role:
├── ECR: Push images only
├── EKS: Describe cluster, update kubeconfig
└── No EC2 or VPC modification permissions

EKS Cluster Role:
├── Manage ENIs and security groups
└── No access to other AWS services

Node Group Role:
├── Pull images from ECR
├── Write logs to CloudWatch
└── No access to S3 or other services
```

### Network Security

**Security Group Rules:**

```
EKS Cluster Security Group:
- Allow: Traffic from ALB
- Allow: Inter-node communication
- Deny: All other inbound

Node Security Group:
- Allow: Traffic from cluster security group
- Allow: HTTPS for ECR pulls
- Deny: Direct internet access on other ports
```

## 📦 Terraform Module Architecture

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
- NAT Gateway (optional)
- Route tables
- Security groups

**Outputs**: VPC ID, subnet IDs, security group IDs

### Module: EKS

**Responsibility**: Kubernetes cluster

**Resources Created**:
- EKS cluster with IAM role
- Node group with launch template
- IRSA (IAM Roles for Service Accounts)
- Add-ons (VPC-CNI, CoreDNS, kube-proxy)

**Outputs**: Cluster endpoint, certificate, name

### Module: ECR

**Responsibility**: Container registries

**Resources Created**:
- 3 ECR repositories (frontend, backend, worker)
- Lifecycle policies (keep last 10 images)
- Repository policies

**Outputs**: Repository URLs

### Module: Kubernetes

**Responsibility**: K8s-level resources

**Resources Created**:
- Namespace
- ConfigMaps
- Secrets
- AWS Load Balancer Controller (via Helm)

**Dependencies**: Requires EKS cluster

### State Management

**Remote backend** with locking:

```hcl
Backend: S3
├── Bucket: purehouse-terraform-state-ohio
├── Key: production/terraform.tfstate
├── Region: us-east-2
└── DynamoDB Lock Table: purehouse-terraform-locks
```

**Benefits:**
- Team collaboration ready
- Prevents concurrent modifications
- State versioning enabled
- Encryption at rest

## 💰 Cost Analysis & Optimization

### Monthly Cost Breakdown

| Service | Configuration | Monthly Cost | Optimization Applied |
|---------|--------------|--------------|---------------------|
| EKS Control Plane | 1 cluster | $73.00 | On-demand destroy |
| EC2 Instances | 2x t3.small | $30.00 | Right-sized, spot-ready |
| NAT Gateway | 1 gateway | $32.00 | Single gateway, or removed |
| ALB | 1 load balancer | $16.00 | Path-based routing |
| ECR Storage | ~5 GB | $0.50 | Lifecycle policies |
| S3 + DynamoDB | State storage | $0.01 | Minimal data |
| **Total** | | **~$151/month** | **~$0.21/hour** |

### Cost Optimization Strategies

**1. On-Demand Infrastructure**
```bash
# Deploy for demos
./scripts/deploy.sh

# Destroy after presentation
./scripts/destroy.sh

# AWS Credits: $120 ÷ $0.21/hr = ~571 demo hours
```

**2. Right-Sized Resources**
- t3.small instead of t3.medium (50% savings)
- Pod resource limits prevent overprovisioning
- Horizontal scaling only when needed

**3. Lifecycle Policies**
- ECR: Keep only last 10 images
- CloudWatch logs: Disabled by default
- S3: Versioning without lifecycle (state files are small)

**4. Single NAT Gateway**
- For production: Multi-AZ NAT recommended
- For demo: Single NAT or public nodes

## 🚀 Deployment Automation

### Shell Scripts for Operations

Created **4 automation scripts** for common operations:

**1. setup-aws.sh** - One-time AWS setup
```bash
Creates:
- S3 bucket for Terraform state
- DynamoDB table for locking
- OIDC provider for GitHub
- IAM role for GitHub Actions
```

**2. deploy.sh** - Full deployment
```bash
Orchestrates:
- Terraform state setup
- Infrastructure provisioning
- Docker image builds
- Kubernetes deployments
- Health checks
```

**3. destroy.sh** - Teardown infrastructure
```bash
Destroys:
- Kubernetes resources
- EKS cluster and nodes
- VPC and networking
- ECR repositories (optional)
```

**4. status.sh** - Check deployment
```bash
Shows:
- Kubernetes pod status
- Service endpoints
- Ingress URL
- Cost estimate
```

## 📊 Monitoring & Observability

### Health Checks

**Application-level**:
```
GET /api/health → Backend health
GET /health     → Worker health
GET /           → Frontend availability
```

**Kubernetes-level**:
```
Liveness:  Restart unhealthy pods
Readiness: Control traffic routing
Startup:   Handle slow boot times
```

### Logging Strategy

**Centralized logging** via kubectl:
```bash
kubectl logs -f deployment/backend -n purehouse
kubectl logs -f deployment/worker -n purehouse
```

**Worker service**: Custom colorized logs for event tracking

### Resource Monitoring

**Kubernetes metrics**:
```bash
kubectl top nodes                    # Node utilization
kubectl top pods -n purehouse        # Pod resources
kubectl describe hpa -n purehouse    # Auto-scaling status
```

## 🧪 Testing Strategy

### Local Development Testing

**Three-terminal setup** for development:
```bash
Terminal 1: cd purehouse-worker && npm run dev
Terminal 2: cd purehouse-backend && npm run start:dev
Terminal 3: cd purehouse-frontend && npm run dev
```

### CI Testing

**Automated tests on every PR**:
- Backend unit tests (Jest)
- Backend e2e tests (Supertest)
- Frontend build validation
- Terraform syntax validation

### Integration Testing

**Post-deployment validation**:
```bash
1. Check pod health: kubectl get pods
2. Test API: curl http://<ALB>/api/health
3. Verify worker: kubectl logs worker-*
```

## 🏆 Skills Demonstrated

### Cloud & Infrastructure
- ✅ AWS multi-service integration (EKS, ECR, VPC, ALB, IAM)
- ✅ Multi-AZ architecture for high availability
- ✅ Cost optimization and resource management
- ✅ Security best practices (OIDC, IRSA, least privilege)

### Infrastructure as Code
- ✅ Terraform modular architecture
- ✅ State management with locking
- ✅ DRY principles and reusability
- ✅ Environment separation

### Kubernetes
- ✅ EKS cluster design and management
- ✅ Deployment strategies (rolling updates)
- ✅ Resource management and auto-scaling
- ✅ Ingress and service mesh basics
- ✅ Secrets and ConfigMaps

### CI/CD
- ✅ GitHub Actions workflows
- ✅ OIDC authentication (modern security)
- ✅ Multi-stage Docker builds
- ✅ Automated testing and deployment

### DevOps Practices
- ✅ GitOps workflow
- ✅ Automation scripts
- ✅ Health checks and observability
- ✅ Documentation and runbooks

## 📚 Technologies Used

### Infrastructure
- **AWS**: EKS, ECR, VPC, ALB, IAM, S3, DynamoDB
- **Terraform**: v1.5+ with modular architecture
- **Kubernetes**: v1.28 on EKS

### CI/CD
- **GitHub Actions**: Workflows with OIDC
- **Docker**: Multi-stage builds
- **Bash**: Automation scripts

### Application
- **Frontend**: Next.js 14, TypeScript
- **Backend**: NestJS, MongoDB Atlas
- **Worker**: Express.js

---

## 🎓 Key Learnings

### Challenges Overcome

**1. OIDC Setup Complexity**
- Challenge: GitHub OIDC → AWS trust relationship
- Solution: IAM role with proper trust policy and thumbprint

**2. ALB Ingress Configuration**
- Challenge: ALB not provisioning automatically
- Solution: Installed AWS Load Balancer Controller via Terraform

**3. Zero-Downtime Deployments**
- Challenge: Service interruption during updates
- Solution: Readiness probes + rolling update strategy

**4. Cost Management**
- Challenge: High AWS costs for demo project
- Solution: On-demand infrastructure with destroy automation

### Best Practices Implemented

- 🔹 Never commit secrets to code
- 🔹 Use OIDC over access keys
- 🔹 Implement health checks for all services
- 🔹 Tag resources for cost tracking
- 🔹 Document infrastructure decisions
- 🔹 Automate common operations
- 🔹 Test locally before deploying

---

*This infrastructure demonstrates production-grade DevOps practices suitable for enterprise environments, while maintaining cost efficiency for portfolio demonstrations.*
