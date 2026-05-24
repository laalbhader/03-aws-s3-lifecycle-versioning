# AWS Static Website Infrastructure with Enterprise-Grade CI/CD & Linting Automation

An automated, secure, and highly scalable production-ready GitOps pipeline that provisions AWS static website hosting infrastructure using Terraform and deploys frontend assets securely via GitHub Actions with built-in code quality gates.

---

## 🏗️ System Architecture

The infrastructure drops direct public S3 bucket access and routes all traffic through a secure, globally optimized content delivery network (CDN).


```

[User Browser] ---> [AWS CloudFront (CDN)] ---> (Origin Access Control) ---> [Secure S3 Bucket]
|
[Lifecycle Policy]
(Auto Purge Cost)

```

### Key Architectural Pillars:
* **Infrastructure as Code (IaC):** 100% automated provisioning using modular Terraform configuration blocks.
* **Origin Access Control (OAC):** Ensures the S3 Bucket strictly denies direct public access, forcing traffic through AWS CloudFront edge locations.
* **Cost Optimization:** Custom S3 Lifecycle configurations automatically purge expired noncurrent object versions after 30 days and clean up incomplete multi-part uploads.
* **Automated Quality Gate (Linting):** Integrated pre-deployment syntax validation to ensure zero broken code reaches production.

---

## 🛠️ Tech Stack & Tools

* **Cloud Provider:** Amazon Web Services (AWS) — S3, CloudFront, IAM
* **Infrastructure Management:** Terraform (IaC)
* **CI/CD Orchestration:** GitHub Actions
* **Code Quality Assurance:** HTMLHint & Stylelint (Node.js runtime environment)

---

## 📂 Repository Structure

```text
├── .github/
│   └── workflows/
│       └── deploy.yml          # Multi-stage GitHub Actions CI/CD pipeline
├── 01-providers.tf            # AWS Provider and Version specifications
├── 02-main.tf                 # Core S3, OAC, and CloudFront Configurations
├── 03-outputs.tf              # Managed infrastructure deployment outputs
├── 04-iam.tf                  # Isolated Deployment Identity & Least-Privilege Policies
├── 05-s3-lifecycle.tf         # Automated cost saving S3 Lifecycle definitions
└── variables.tf               # Clean parameterized input variable maps

```

---

## 🚀 Pipeline Workflow (GitHub Actions)

The workflow executes sequentially on every code push to the `main` branch:

```
┌────────────────────────┐
│  Trigger: Push to Main │
└───────────┬────────────┘
            ▼
┌────────────────────────┐
│ 1. Runtime Provisioning│ -> Allocates isolated Ubuntu runner environment
└───────────┬────────────┘
            ▼
┌────────────────────────┐
│ 2. Code Quality Check  │ -> Runs HTMLHint and Stylelint (Halts if syntax is broken)
└───────────┬────────────┘
            ▼
┌────────────────────────┐
│ 3. AWS Authentication  │ -> Assumes safe session using GitHub Secrets
└───────────┬────────────┘
            ▼
┌────────────────────────┐
│ 4. S3 Synchronization  │ -> Executes optimized AWS CLI S3 Sync operation
└────────────────────────┘

```

---

## ⚙️ Deployment & Usage Instructions

### 1. Prerequisites

Ensure you have the AWS CLI and Terraform installed locally, and secure GitHub Secrets configured:

* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`

### 2. Infrastructure Provisioning

Initialize and apply the Terraform modules to spin up the cloud infrastructure:

```bash
# Initialize working directory and download providers
terraform init

# Validate configuration syntax
terraform validate

# Review the execution plan
terraform plan

# Deploy infrastructure to AWS
terraform apply -auto-approve

```

### 3. Automated Application Deployment

Simply commit your frontend assets and push to your stable production branch:

```bash
git add .
git commit -m "feat: updated website layout and added code quality verification"
git push origin main

```

The automated quality gate will immediately trigger, validate your HTML/CSS syntax, and securely sync valid code directly to your globally distributed CloudFront CDN edge origin.

---

## 🔒 Security & Best Practices Implemented

* **Zero Hardcoded Values:** Complete decoupled architecture utilizing parameterized variables for dynamic scale.
* **Strict Least-Privilege Access:** The CI/CD runtime deployment identity is restricted exclusively to targeted S3 actions.
* **Data Resilience:** Enabled S3 Bucket Versioning to guard against accidental object overrides and modifications.

```

```