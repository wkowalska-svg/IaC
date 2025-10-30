variable "project_id" { 
  type = string
  description = "GCP project ID"
}
variable "region" { 
  type = string 
  default = "us-central1" 
}
variable "vpc_name" { 
  type = string
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
  type = string
}