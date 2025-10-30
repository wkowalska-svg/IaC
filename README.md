# Bootstrap Terraform State

Initializes Terraform state for a GCP project.

```bash
scripts/bootstrap_all.sh <PROJECT_ID> [state-bucket-name] [region]
```

- Creates a Terraform state bucket (default: tf-state-<PROJECT_ID>).
- Enables required GCP APIs.
- Grants necessary IAM roles to the Cloud Build service account.
- Must be run in a GCP environment (e.g., Cloud Shell) before using the pipeline.

# GCP Infrastructure with Terraform
This Terraform configuration provisions a complete Google Cloud Platform (GCP) environment that includes networking, IAM permissions, and virtual machines (VMs).  

## Modules Overview

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

## Variables

| Name | Type | Default | Description |
|------|------|----------|-------------|
| `project_id` | string | — | GCP Project ID |
| `region` | string | `us-central1` | GCP region |
| `vpc_name` | string | `prod-vpc` | VPC name |
| `subnets` | map(object) | see below | Subnet definitions |
| `vm_user_email` | string | — | User email for SSH access |

**Default Subnets:**
```
subnets = {
  subnet-a = { cidr = "10.0.1.0/24", region = "us-central1" }
  subnet-b = { cidr = "10.0.2.0/24", region = "us-central1" }
}
```

## Outputs
| Name | Description |
|------|-------------|
| `vpc_self_link` | Self link of the created VPC |
| `subnets` | Map of subnet self links |
| `vm_ip` | External IP address of the primary VM |

## Backend Configuration
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
terraform init
```
2.Review the execution plan
```
terraform plan -var="project_id=your-gcp-project-id" -var="vm_user_email=you@example.com"
```
3. Apply changes
```
terraform apply -var="project_id=your-gcp-project-id" -var="vm_user_email=you@example.com"
```
4. Destroy changes
```
terraform destroy -var="project_id=your-gcp-project-id" -var="vm_user_email=you@example.com"
```