variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "alert_email" {
  type        = string
  description = "Email address for alert notifications"
}

variable "region" {
  type        = string
  description = "GCP region for logging bucket"
}