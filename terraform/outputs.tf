output "vpc_self_link" {
  description = "Self link of the VPC network"
  value       = module.network.vpc_self_link
}

output "subnets" {
  description = "Map of subnet self links"
  value       = module.network.subnet_self_links
}

output "vm_ip" {
  description = "External IP address of the primary VM"
  value       = module.vm.external_ip
}

output "cloudbuild_triggers" {
  description = "Cloud Build trigger IDs"
  value = {
    pr_trigger   = module.cloudbuild.pr_trigger_id
    main_trigger = module.cloudbuild.main_trigger_id
  }
}

output "github_connection" {
  description = "GitHub connection name for Cloud Build"
  value       = module.cloudbuild.github_connection_name
}

output "github_repository" {
  description = "GitHub repository name for Cloud Build"
  value       = module.cloudbuild.github_repository_name
}

output "build_service_account" {
  description = "Service account used for Cloud Build executions"
  value       = module.cloudbuild.build_service_account
}