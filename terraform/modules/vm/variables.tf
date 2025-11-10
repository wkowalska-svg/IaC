variable "name" { type = string }
variable "region" { type = string }
variable "subnet" { type = string }
variable "machine_type" {
  type    = string
  default = "e2-micro"
}
variable "image" {
  type    = string
  default = "debian-cloud/debian-12"
}