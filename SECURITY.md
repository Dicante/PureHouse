# Security Policy

## 🔒 Security Best Practices

This repository follows security best practices for DevOps projects:

### ✅ What We Do

- **No credentials in code**: All secrets are managed via environment variables
- **`.gitignore` protection**: Sensitive files (`.env`, `*.tfvars`) are ignored
- **Example files only**: Only `.example` files with placeholder values are committed
- **OIDC authentication**: GitHub Actions uses OpenID Connect (no AWS keys stored)
- **Terraform remote state**: State files stored in S3 with encryption and locking

### 🚫 Never Commit

The following files should **NEVER** be committed to Git:

- `*.env` (except `.env.example`)
- `*.tfvars` (except `*.tfvars.example`)
- AWS credentials or access keys
- MongoDB connection strings with real passwords
- Private keys (`.pem`, `.key`)
- Terraform state files (`.tfstate`)

### 🔐 Files Already Protected

These files are in `.gitignore` and will never be committed:

```
.env
*.tfvars
.terraform/
*.tfstate
*.key
*.pem
```

### 📋 Before Making Changes

If you fork or clone this repository:

1. **Never commit real credentials**
   ```bash
   # Always use .example files as templates
   cp .env.example .env
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Verify .gitignore is working**
   ```bash
   # These commands should return empty (no files)
   git ls-files | grep "\.env$"
   git ls-files | grep "terraform.tfvars$"
   ```

3. **Check for accidental commits**
   ```bash
   # Search for potential secrets
   git log --all --full-history --source -- "*.env" "*.tfvars"
   ```

## 🐛 Reporting Security Issues

This is a portfolio/educational project. If you find a security concern:

1. **Do NOT open a public issue**
2. Email me directly: juliandicante@outlook.com
3. I will respond within 48 hours

## 🔄 Credential Rotation

If you accidentally commit credentials:

1. **Immediately rotate them** (change passwords, regenerate keys)
2. Remove from Git history using `git filter-branch` or BFG Repo-Cleaner
3. Force push the cleaned history
4. Verify on GitHub that the credentials are gone

### Tools for cleaning Git history:

```bash
# Option 1: BFG Repo-Cleaner (recommended)
bfg --replace-text passwords.txt
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# Option 2: git filter-branch
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch path/to/secret/file' \
  --prune-empty --tag-name-filter cat -- --all
```

## ✅ Current Security Status

- ✅ No AWS keys in repository
- ✅ No MongoDB credentials in repository
- ✅ All sensitive files properly ignored
- ✅ OIDC used for GitHub Actions (no long-lived credentials)
- ✅ Example files contain only placeholder values
- ✅ MIT License protects intellectual property

Last security audit: November 10, 2025
