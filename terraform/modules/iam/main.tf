# Fetch project info dynamically
data "google_project" "current" {
  project_id = var.project_id
}

# Local variable for Cloud Build SA email
locals {
  cloud_build_sa    = var.cloud_build_sa != "" ? var.cloud_build_sa : "${data.google_project.current.number}@cloudbuild.gserviceaccount.com"
  cloud_build_agent = "service-${data.google_project.current.number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "vm_user_ssh" {
  project = var.project_id
  role    = "roles/compute.osLogin"
  member  = "user:${var.vm_user_email}"
}

# Assign IAM role to Cloud Build SA
resource "google_project_iam_member" "cloud_build_compute" {
  project = var.project_id
  role    = "roles/compute.instanceAdmin.v1"
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
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${local.cloud_build_sa}"
}

resource "google_project_iam_member" "cloudbuild_agent_service_agent" {
  project = var.project_id
  role    = "roles/cloudbuild.serviceAgent"
  member  = "serviceAccount:${local.cloud_build_agent}"
}


resource "google_project_iam_member" "cloudbuild_agent_secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${local.cloud_build_agent}"
}


resource "google_project_iam_member" "cloudbuild_sa_secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${local.cloud_build_sa}"
}


resource "google_project_iam_member" "cloudbuild_logs" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${local.cloud_build_sa}"
}

resource "google_project_iam_member" "cloudbuild_logging_config" {
  project = var.project_id
  role    = "roles/logging.configWriter"
  member  = "serviceAccount:${local.cloud_build_sa}"
}
