variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region for Cloud Build"
  type        = string
  default     = "us-central1"
}

variable "state_bucket" {
  description = "GCS bucket name for Terraform state"
  type        = string
  default     = ""
}

variable "cloud_build_sa" {
  description = "The Cloud Build service account"
  type        = string
}

variable "vm_user_email" {
  description = "Email of the user to give SSH access to the VM"
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

variable "alert_email" {
  type        = string
  description = "Email used by Cloud Build in CI pipeline for monitoring alerts"
}