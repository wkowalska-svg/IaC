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
  source  = "./modules/vm"
  name    = "demo-web"
  region  = var.region
  subnet  = module.network.subnet_self_links["subnet-a"]
}
module "iam" {
  source     = "./modules/iam"
  project_id = var.project_id
  vm_user_email = var.vm_user_email
}