# Fetch project info dynamically
data "google_project" "current" {
  project_id = var.project_id
}

# Local variable for Cloud Build SA email
locals {
  cloud_build_sa = "${data.google_project.current.number}@cloudbuild.gserviceaccount.com"
}

resource "google_project_service" "cloud_build_api" {
  project = var.project_id
  service = "cloudbuild.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_iam_member" "vm_user_ssh" {
  project = var.project_id
  role    = "roles/compute.osLogin"
  member  = "user:${var.vm_user_email}"
}

# Assign IAM role to Cloud Build SA
resource "google_project_iam_member" "cloud_build_compute" {
  project = var.project_id
  role    = "roles/compute.admin"
  member  = "serviceAccount:${local.cloud_build_sa}"
}

resource "google_project_iam_member" "cloud_build_network" {
  project = var.project_id
  role    = "roles/compute.networkAdmin"
  member  = "serviceAccount:${local.cloud_build_sa}"
}

resource "google_project_iam_member" "cloud_build_iam" {
  project = var.project_id
  role    = "roles/iam.securityAdmin"
  member  = "serviceAccount:${local.cloud_build_sa}"
}

resource "google_project_iam_member" "cloud_build_storage" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${local.cloud_build_sa}"
}

resource "google_project_iam_member" "cloud_build_monitoring" {
  project = var.project_id
  role    = "roles/monitoring.editor"
  member  = "serviceAccount:${local.cloud_build_sa}"
}

resource "google_project_iam_member" "cloud_build_serviceusage" {
  project = var.project_id
  role    = "roles/serviceusage.serviceUsageAdmin"
  member  = "serviceAccount:${local.cloud_build_sa}"
}