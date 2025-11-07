variable "project_id" { type = string }
variable "cloud_build_sa" {
  type    = string
  default = ""
}
variable "vm_user_email" {
  description = "Email of the user to give SSH access to the VM"
  type        = string
}