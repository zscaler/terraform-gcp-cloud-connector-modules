output "private_ip" {
  description = "Instance Private IP"
  value       = google_compute_instance.server_host.network_interface[0].network_ip
}

output "network_tag" {
  description = "Network tag as the source of a route rule"
  value       = google_compute_instance.server_host.name
}
