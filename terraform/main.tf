provider "google" {
  project = var.project_id
  region  = var.region
}

module "network" {
  source   = "./modules/network"
  vpc_name = var.vpc_name
  subnets  = var.subnets
}

module "vm" {
  source = "./modules/vm"
  name   = "demo-web"
  region = var.region
  subnet = module.network.subnet_self_links["subnet-a"]
}

module "iam" {
  source         = "./modules/iam"
  project_id     = var.project_id
  vm_user_email  = var.vm_user_email
  cloud_build_sa = var.cloud_build_sa
}

module "cloudbuild" {
  source                     = "./modules/cloudbuild"
  project_id                 = var.project_id
  region                     = var.region
  state_bucket               = var.state_bucket
  cloud_build_sa             = module.iam.cloud_build_sa
  vm_user_email              = var.vm_user_email
  github_repo_url            = var.github_repo_url
  github_app_installation_id = var.github_app_installation_id
  alert_email                = var.alert_email

  depends_on = [module.iam]
}

module "monitoring" {
  source      = "./modules/monitoring"
  project_id  = var.project_id
  alert_email = var.alert_email
  region      = var.region
}
