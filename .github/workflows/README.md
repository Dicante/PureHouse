# CI/CD Pipeline Implementation

> GitHub Actions workflows with OIDC authentication for secure AWS deployment

## 🎯 Overview

Implemented a **complete CI/CD pipeline** using GitHub Actions with modern security practices. Demonstrates understanding of automated testing, containerization, and secure cloud deployments.

## 🏗️ Pipeline Architecture

### Two-Stage Pipeline Design

```
┌─────────────────────────────────────────┐
│  Feature Branch                          │
│  └─> Pull Request                        │
│       └─> CI Workflow                    │
│            ├─> Run all tests            │
│            ├─> Validate builds          │
│            └─> Block if fails ❌        │
└─────────────────────────────────────────┘
                    │
                    ▼ (Merge approved)
┌─────────────────────────────────────────┐
│  Main Branch                             │
│  └─> Push event                          │
│       └─> CD Workflow                    │
│            ├─> Build Docker images      │
│            ├─> Push to ECR              │
│            ├─> Deploy to EKS            │
│            └─> Rolling update ✅        │
└─────────────────────────────────────────┘
```

## 🔐 Security Implementation: OIDC Authentication

### The Problem with Traditional Authentication

**Old way** (Security anti-pattern):
```yaml
# ❌ Long-lived credentials stored in GitHub
secrets:
  AWS_ACCESS_KEY_ID: "AKIA..."
  AWS_SECRET_ACCESS_KEY: "wJalr..."
```

**Issues**:
- Credentials can be stolen if leaked
- Manual rotation required
- No audit trail of which workflow used them
- Violates principle of least privilege

### Modern Solution: OIDC (What I Implemented)

**OIDC Authentication Flow**:

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
│  Credentials │ • Access Key
│              │ • Secret Key
│              │ • Session Token
└──────────────┘
```

**Implementation**:

```yaml
permissions:
  id-token: write    # Required for OIDC token request
  contents: read

steps:
  - name: Configure AWS credentials
    uses: aws-actions/configure-aws-credentials@v4
    with:
      role-to-assume: arn:aws:iam::${{ secrets.AWS_ACCOUNT_ID }}:role/github-actions-role
      aws-region: us-east-2
```

**Benefits**:
- ✅ No stored credentials
- ✅ Automatic expiration (1 hour)
- ✅ Audit trail via CloudTrail
- ✅ Follows AWS security best practices

### IAM Role Configuration

**Trust Policy** (allows GitHub to assume role):

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
    },
    "Action": "sts:AssumeRoleWithWebIdentity",
    "Condition": {
      "StringEquals": {
        "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
      },
      "StringLike": {
        "token.actions.githubusercontent.com:sub": "repo:USERNAME/PureHouse:*"
      }
    }
  }]
}
```

**Key security features**:
- Only this specific repository can assume role
- Only GitHub Actions can use it (not human users)
- Scoped to minimum required permissions (ECR push, EKS deploy)

## 🔄 CI Workflow - Continuous Integration

### Purpose
**Validate code quality before merge** to prevent broken code from reaching production.

### Trigger
```yaml
on:
  pull_request:
    branches: [main]
```

### Jobs Breakdown

**1. test-backend**
```yaml
- Checkout code
- Setup Node.js 18
- Install dependencies
- Run unit tests (Jest)
- Run e2e tests (Supertest)
```

**2. test-frontend**
```yaml
- Checkout code
- Setup Node.js 18
- Install dependencies
- Build Next.js app (validates TypeScript)
```

**3. test-worker**
```yaml
- Checkout code
- Setup Node.js 18
- Install dependencies
- Run tests
```

**4. validate-terraform** (optional)
```yaml
- Checkout code
- Setup Terraform
- terraform fmt -check
- terraform validate
```

### CI Strategy

**Fast feedback loop**:
- Runs in parallel (faster results)
- Fails fast (stops on first error)
- Blocks merge if any test fails
- Costs $0 (GitHub Actions free tier)

## 🚀 CD Workflow - Continuous Deployment

### Purpose
**Automatically deploy to EKS** when code is merged to main branch.

### Trigger
```yaml
on:
  push:
    branches: [main]
```

### Jobs Breakdown

**1. build-and-push**

```yaml
Steps:
1. Checkout code
2. Configure AWS credentials (OIDC)
3. Login to Amazon ECR
4. Build Docker images:
   - purehouse-backend
   - purehouse-frontend
   - purehouse-worker
5. Tag images:
   - latest
   - git-sha-123abc
6. Push to ECR repositories
```

**Why multi-tagging**:
- `latest`: Always points to production
- `git-sha`: Enables rollback to specific commit

**2. deploy**

```yaml
Steps:
1. Configure AWS credentials (OIDC)
2. Update kubeconfig:
   aws eks update-kubeconfig --name purehouse-production
3. Replace ACCOUNT_ID in manifests:
   sed -i "s/ACCOUNT_ID/$AWS_ACCOUNT_ID/g" kubernetes/**/*.yaml
4. Apply Kubernetes manifests:
   kubectl apply -f kubernetes/
5. Wait for rollout:
   kubectl rollout status deployment/backend -n purehouse
   kubectl rollout status deployment/frontend -n purehouse
   kubectl rollout status deployment/worker -n purehouse
6. Get Ingress URL:
   kubectl get ingress -n purehouse
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
5. Repeat for each pod

## 📊 Monitoring & Observability

### Workflow Logs

**View in GitHub**:
```
Repository → Actions → Workflow run
```

**Logs include**:
- Build output
- Test results
- kubectl apply output
- Deployment status
- Ingress URL

### Deployment Verification

**Post-deployment checks**:
```bash
# Check pods
kubectl get pods -n purehouse

# Check services
kubectl get svc -n purehouse

# Check ingress
kubectl get ingress -n purehouse

# View logs
kubectl logs -f deployment/backend -n purehouse
```

## 💡 Technical Highlights

### Skills Demonstrated

- ✅ **GitHub Actions**: Workflow creation, job orchestration, matrix builds
- ✅ **OIDC Authentication**: Modern security without stored credentials
- ✅ **Docker**: Multi-stage builds, image tagging strategies
- ✅ **AWS ECR**: Container registry management
- ✅ **Kubernetes**: kubectl automation, rolling updates
- ✅ **CI/CD Best Practices**: Test before deploy, fail fast, atomic deployments
- ✅ **Infrastructure as Code**: Declarative Kubernetes manifests
- ✅ **GitOps**: Git as source of truth

### Advanced Patterns Used

**1. Job Dependencies**
```yaml
jobs:
  build:
    runs-on: ubuntu-latest
  deploy:
    needs: build          # Wait for build to complete
    runs-on: ubuntu-latest
```

**2. Conditional Execution**
```yaml
if: github.ref == 'refs/heads/main'    # Only on main branch
```

**3. Secrets Management**
```yaml
env:
  MONGODB_URI: ${{ secrets.MONGODB_URI }}
```

**4. Matrix Builds** (not implemented, but could scale to):
```yaml
strategy:
  matrix:
    service: [backend, frontend, worker]
```

## 🏆 Comparison with Alternatives

| Tool | Pros | Cons | Why Not Chosen |
|------|------|------|----------------|
| **GitHub Actions** ✅ | Native integration, free tier | GitHub-specific | Chosen for this project |
| Jenkins | Self-hosted, flexible | Maintenance overhead | Too complex for demo |
| GitLab CI | All-in-one platform | Requires GitLab | Using GitHub |
| CircleCI | Fast, good caching | Costs for private repos | GitHub Actions sufficient |
| AWS CodePipeline | Native AWS | Complex setup, costs | GitHub Actions simpler |

## 🧪 Testing the Pipeline

### Test CI Workflow
```bash
# Create feature branch
git checkout -b feature/test

# Make changes
# ...

# Push and create PR
git push origin feature/test
# Open PR on GitHub → CI workflow triggers
```

### Test CD Workflow
```bash
# Merge PR to main
git checkout main
git merge feature/test
git push origin main
# CD workflow triggers automatically
```

## 📈 Future Enhancements

**Production improvements** (not implemented):

1. **Environment-specific deployments**
   - Staging environment before production
   - Manual approval gates

2. **Rollback automation**
   - Automatic rollback on health check failure
   - One-click rollback to previous version

3. **Notifications**
   - Slack/Discord deployment notifications
   - Email on failure

4. **Performance testing**
   - Load testing before production deploy
   - Smoke tests after deployment

**Why not implemented**: Demo project scope, cost optimization

---

*This CI/CD implementation showcases modern DevOps practices with security-first design, demonstrating production-ready automation skills.*
# GitHub Actions EKS Access Configured
