output "next_hop_ilb_ip_address" {
  description = "ILB front end IP address"
  value       = google_compute_forwarding_rule.ilb_forwarding.ip_address
}

output "next_hop_ilb" {
  description = "ID for ILB IP"
  value       = google_compute_forwarding_rule.ilb_forwarding.self_link
}

output "ilb_ip_address" {
  description = "IP address designated for ILB"
  value       = google_compute_address.ilb_ip_address.address
}

output "ilb_ip_address_link" {
  description = "ID for ILB designated compute address"
  value       = google_compute_address.ilb_ip_address.self_link
}
