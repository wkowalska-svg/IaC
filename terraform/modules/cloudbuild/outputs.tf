output "pr_trigger_id" {
  description = "ID of the Pull Request trigger"
  value       = google_cloudbuild_trigger.pr_plan.id
}

output "main_trigger_id" {
  description = "ID of the Main branch trigger"
  value       = google_cloudbuild_trigger.main_apply.id
}

output "github_connection_name" {
  description = "Name of the GitHub connection"
  value       = google_cloudbuildv2_connection.github_connection.name
}

output "github_repository_name" {
  description = "Name of the GitHub repository"
  value       = google_cloudbuildv2_repository.github-repository.name
}

output "build_service_account" {
  description = "Service account used for Cloud Build"
  value       = local.service_account_email
}

