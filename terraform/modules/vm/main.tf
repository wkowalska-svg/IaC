resource "google_compute_instance" "vm" {
  name         = var.name
  machine_type = var.machine_type
  zone         = "${var.region}-a"
  boot_disk {
    initialize_params {
      image = var.image
    }
  }
  network_interface {
    subnetwork = var.subnet
    access_config {}
  }
  metadata = {
    enable-oslogin = "TRUE"
  }
  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
  EOT
  tags                    = ["http-server"]
}
resource "google_compute_instance" "vm2" {
  name         = "${var.name}-2"
  machine_type = var.machine_type
  zone         = "${var.region}-a"
  boot_disk {
    initialize_params {
      image = var.image
    }
  }
  network_interface {
    subnetwork = var.subnet
    access_config {}
  }
  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
  EOT
  tags                    = ["http-server"]
}


/*
resource "google_compute_instance" "invalid" {
  name         = "fail-test"
  machine_type = "INVALID_TYPE"  # <-- This will fail
  zone         = "us-central1-a"
  boot_disk { 
    initialize_params { 
      image = var.image 
    } 
  }
  network_interface { 
    subnetwork = var.subnet 
    access_config {} 
  }
}
*/