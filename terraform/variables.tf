variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "vpc_name" {
  type    = string
  default = "prod-vpc"
}

variable "subnets" {
  type = map(object({ cidr = string, region = string }))
  default = {
    subnet-a = { cidr = "10.0.1.0/24", region = "us-central1" }
    subnet-b = { cidr = "10.0.2.0/24", region = "us-central1" }
  }
}

variable "vm_user_email" {
  description = "Email of the user to give SSH access to the VM"
  type        = string
}

variable "cloud_build_sa" {
  description = "Email of the Cloud Build service account"
  type        = string
}

variable "state_bucket" {
  description = "GCS bucket name for Terraform state (created by bootstrap script)"
  type        = string
}

variable "github_repo_url" {
  description = "URL of the GitHub repository"
  type        = string
}

variable "github_app_installation_id" {
  description = "GitHub App Installation ID"
  type        = string
}
