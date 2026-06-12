output "next_hop_glb_ip_address" {
  description = "ILB front end IP address"
  value       = google_compute_forwarding_rule.glb_forwarding.ip_address
}

output "next_hop_glb" {
  description = "ID for ILB IP"
  value       = google_compute_forwarding_rule.glb_forwarding.self_link
}

output "glb_ip_address" {
  description = "IP address designated for ILB"
  value       = google_compute_address.glb_ip_address.address
}

output "glb_ip_address_link" {
  description = "ID for ILB designated compute address"
  value       = google_compute_address.glb_ip_address.self_link
}
