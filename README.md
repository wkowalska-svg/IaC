# GCP Infrastructure as Code with Terraform & Cloud Build

This repository contains Terraform configurations for provisioning GCP infrastructure with automated CI/CD using Cloud Build.

## 📋 Prerequisites

### 1. GitHub Personal Access Token

Before running the bootstrap script, you need a GitHub Personal Access Token with the following scopes:

- `repo` - Full control of private repositories
- `admin:repo_hook` - Full control of repository hooks
- `admin:public_key` - Full control of user public keys
- `user` - Read user profile information
- `workflow` - Update GitHub Action workflows

**Create a token at:** https://github.com/settings/tokens

⚠️ **Keep this token secure** - it will be stored in Google Secret Manager.

### 2. GitHub App Installation ID

To integrate Cloud Build with your GitHub repository, you need to install the Google Cloud Build app:

1. Go to the **Google Cloud Build GitHub App** installation page:
   - https://github.com/apps/google-cloud-build
2. Click **"Configure"** or **"Install"**
3. Select your GitHub account/organization
4. Choose the repository you want to connect
5. After installation, note the **Installation ID** from the URL:
   - URL format: `https://github.com/settings/installations/XXXXXXXX`
   - The number at the end is your **installation ID**

---

## 🛠️ Bootstrap Setup

### Run Bootstrap Script

The bootstrap script initializes your GCP project with all necessary APIs, service accounts, and the Terraform state bucket.

```bash
scripts/bootstrap_all.sh <PROJECT_ID> [state-bucket-name] [region]
```

- Creates a Terraform state bucket (default: tf-state-<PROJECT_ID>).
- Enables required GCP APIs.
- Grants necessary IAM roles to the Cloud Build service account.
- Must be run in a GCP environment (e.g., Cloud Shell) before using the pipeline.
- Prompts for GitHub OAuth token and stores it in Secret Manager. (Input will be hidden for security)

Sometimes when you copy it from Windows to Linux this might be needed (fixes the line endings):

```
sed -i 's/\r$//' scripts/bootstrap_all.sh
```

Plus also setting rights:

```
chmod +x scripts/bootstrap_all.sh
```

# GCP Infrastructure with Terraform

This Terraform configuration provisions a complete Google Cloud Platform (GCP) environment that includes networking, IAM permissions, and virtual machines (VMs).

## Modules Overview

### **CloudBuild Module**

Manages automated Terraform CI/CD pipeline integration with GitHub.

**Features:**

- Creates Cloud Build v2 connection to GitHub
- Links GitHub repository to Cloud Build
- Configures two triggers:
  - **PR Plan Trigger**: Runs on pull requests to `main` or `master` (format check, validation, plan)
  - **Main Apply Trigger**: Runs on push to `main` or `master` (plan, apply, backup)
- Uses GitHub App authentication with OAuth token from Secret Manager
- Configures custom service account for secure operations

### **IAM Module**

- Dynamically fetches the GCP project details.
- Grants required IAM roles to:
  - Cloud Build Service Account
  - VM user (for SSH access)
- Enables essential APIs (Cloud Build).

### **Network Module**

Creates a VPC, subnets, and firewall rules for SSH, HTTP, and internal communication.

**Firewall Rules:**
| Rule | Description | Ports | Source |
|------|--------------|--------|---------|
| allow-ssh | SSH access | 22 | 0.0.0.0/0 |
| allow-http | HTTP traffic | 80 | 0.0.0.0/0 |
| allow-internal | Internal communication | all | subnet CIDRs |

### **VM Module**

Deploys two Compute Engine instances (VMs) with Nginx pre-installed.

**Features:**

- OS Login enabled
- Startup script to install Nginx
- Tags: `http-server`
- Public IP access

## 🔧 Variables

| Name                         | Type        | Required | Default                                             | Description                          |
| ---------------------------- | ----------- | -------- | --------------------------------------------------- | ------------------------------------ |
| `project_id`                 | string      | ✅       | —                                                   | GCP Project ID                       |
| `vm_user_email`              | string      | ✅       | —                                                   | User email for SSH access (OS Login) |
| `github_repo_url`            | string      | ✅       | —                                                   | Full GitHub repository URL           |
| `state_bucket`               | string      | ✅       | —                                                   | GCS bucket for Terraform state       |
| `github_app_installation_id` | string      | ✅       | —                                                   | GitHub App installation ID           |
| `cloud_build_sa`             | string      | ✅       | `cloudbuild-runner@PROJECT.iam.gserviceaccount.com` | Cloud Build service account email    |
| `region`                     | string      |          | `us-central1`                                       | GCP region                           |
| `vpc_name`                   | string      |          | `prod-vpc`                                          | VPC name                             |
| `subnets`                    | map(object) |          | see below                                           | Subnet definitions                   |

**Default Subnets:**

```
subnets = {
  subnet-a = { cidr = "10.0.1.0/24", region = "us-central1" }
  subnet-b = { cidr = "10.0.2.0/24", region = "us-central1" }
}
```

## Outputs

| Name                       | Description                           |
| -------------------------- | ------------------------------------- |
| `vpc_self_link`            | Self link of the created VPC          |
| `subnets`                  | Map of subnet self links              |
| `vm_ip`                    | External IP address of the primary VM |
| `cloudbuild_connection_id` | Cloud Build GitHub connection ID      |
| `cloudbuild_repository_id` | Cloud Build repository ID             |

## 🔐 Backend Configuration

The project uses **Google Cloud Storage (GCS)** for storing the Terraform state:

```
terraform {
  backend "gcs" {
    prefix = "terraform/state"
  }
}
```

Make sure you have a GCS bucket created and configured before running terraform init.

## Usage

1. Initialize Terraform

```
terraform init -backend-config="bucket=state-bucket-name"
```

- state-bucket-name → the name of the GCS bucket created via the bootstrap process.
  2.Review the execution plan

```
terraform plan -var="project_id=your-gcp-project-id" -var="vm_user_email=you@example.com" -var="cloud_build_sa=your_cloud_build_sa_email" -var="state_bucket="created_state_bucket" -var="github_repo_url=repo_url" -var="github_app_installation_id=your_github_app_installation_id"
```

3. Apply changes

```
terraform apply -var="project_id=your-gcp-project-id" -var="vm_user_email=you@example.com"
-var="cloud_build_sa=your_cloud_build_sa_email" -var="state_bucket="created_state_bucket" -var="github_repo_url=repo_url" -var="github_app_installation_id=your_github_app_installation_id"
```

4. Destroy changes

```
terraform destroy -var="project_id=your-gcp-project-id" -var="vm_user_email=you@example.com"
```

---

### Automated Workflow

Once the bootstrap and initial setup are complete, Cloud Build will automatically manage your infrastructure:

1. **Create a feature branch:**

   ```bash
   git checkout -b feat/my-changes
   ```

2. **Make your Terraform changes** in the `terraform/` directory

3. **Push and create a Pull Request to `master`:**

   ```bash
   git push origin feat/my-changes
   ```

4. **Cloud Build automatically runs** `terraform plan`:

   - Checks formatting (`terraform fmt`)
   - Validates configuration (`terraform validate`)
   - Generates execution plan
   - Saves plan artifacts to GCS

5. **Review the plan** in Cloud Build logs (check PR for link)

6. **Merge the PR** - Cloud Build automatically runs `terraform apply`:
   - Applies the planned changes
   - Backs up apply logs to GCS
   - Outputs infrastructure details

**View builds:** https://console.cloud.google.com/cloud-build/builds
**Artifacts location:** `gs://YOUR-STATE-BUCKET/builds/BUILD-ID/`
**Deployment logs:** `gs://YOUR-STATE-BUCKET/deployments/`
