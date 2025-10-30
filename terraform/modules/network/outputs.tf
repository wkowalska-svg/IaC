output "vpc_self_link" { value = google_compute_network.vpc.self_link }
output "subnet_self_links" { value = { for k, v in google_compute_subnetwork.subnet : k => v.self_link } }