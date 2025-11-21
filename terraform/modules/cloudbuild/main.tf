data "google_project" "current" {
  project_id = var.project_id
}

locals {
  service_account_email = var.cloud_build_sa
  github_token_version  = "projects/${data.google_project.current.number}/secrets/github-oauth-token/versions/latest"
}

resource "google_cloudbuildv2_connection" "github_connection" {
  location = var.region
  name     = "github-connection"

  github_config {
    app_installation_id = var.github_app_installation_id
    authorizer_credential {
      oauth_token_secret_version = local.github_token_version
    }
  }
}

resource "google_cloudbuildv2_repository" "github-repository" {
  location = var.region
  name     = "github-repository"

  parent_connection = google_cloudbuildv2_connection.github_connection.name
  remote_uri        = var.github_repo_url
}

resource "google_cloudbuild_trigger" "pr_plan" {
  location    = var.region
  name        = "pr-terraform-plan"
  description = "Run terraform plan on pull requests for validation"

  repository_event_config {
    repository = google_cloudbuildv2_repository.github-repository.id

    pull_request {
      branch = "^(main|master)$"
    }
  }

  filename = "workflows/cloudbuild-plan.yaml"

  substitutions = {
    _STATE_BUCKET               = var.state_bucket
    _VM_USER_EMAIL              = var.vm_user_email
    _GITHUB_REPO_URL            = var.github_repo_url
    _GITHUB_APP_INSTALLATION_ID = var.github_app_installation_id
    _CLOUD_BUILD_SA             = local.service_account_email
    _ALERT_EMAIL                = var.alert_email
  }

  service_account = "projects/${var.project_id}/serviceAccounts/${local.service_account_email}"

}

resource "google_cloudbuild_trigger" "main_apply" {
  location    = var.region
  name        = "main-terraform-apply"
  description = "Run terraform apply on push to main branch"

  repository_event_config {
    repository = google_cloudbuildv2_repository.github-repository.id

    push {
      branch = "^(main|master)$"
    }
  }

  filename = "workflows/cloudbuild-apply.yaml"

  substitutions = {
    _STATE_BUCKET               = var.state_bucket
    _VM_USER_EMAIL              = var.vm_user_email
    _GITHUB_REPO_URL            = var.github_repo_url
    _GITHUB_APP_INSTALLATION_ID = var.github_app_installation_id
    _CLOUD_BUILD_SA             = local.service_account_email
    _ALERT_EMAIL                = var.alert_email
  }

  service_account = "projects/${var.project_id}/serviceAccounts/${local.service_account_email}"

}



