resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "subnet" {
  for_each                 = var.subnets
  name                     = each.key
  ip_cidr_range            = each.value.cidr
  region                   = each.value.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true
}
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.vpc_name}-allow-ssh"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
}
resource "google_compute_firewall" "allow-internal" {
  name    = "${var.vpc_name}-allow-internal"
  network = google_compute_network.vpc.name
  allow { protocol = "all" }
  source_ranges = [for s in var.subnets : s.cidr]
}
resource "google_compute_firewall" "allow-http" {
  name    = "${var.vpc_name}-allow-http"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["0.0.0.0/0"]
}