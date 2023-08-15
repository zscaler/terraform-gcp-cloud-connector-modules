output "cc_management_ip" {
  description = "CC VM internal management IP"
  value       = data.google_compute_instance.cc_vm_instances[*].network_interface[1].network_ip
}

output "cc_forwarding_ip" {
  description = "CC VM internal forwarding IP"
  value       = data.google_compute_instance.cc_vm_instances[*].network_interface[0].network_ip
}

output "instance_group_zones" {
  description = "GCP Zone assigmnents for Instance Groups"
  value       = google_compute_instance_group_manager.cc_instance_group_manager[*].zone
}

output "instance_group_names" {
  description = "Name for Instance Groups"
  value       = google_compute_instance_group_manager.cc_instance_group_manager[*].name
}

output "instance_group_ids" {
  description = "Name for Instance Groups"
  value       = google_compute_instance_group_manager.cc_instance_group_manager[*].instance_group
}

output "instance_template_region" {
  description = "GCP Region for Compute Instance Template and resource placement"
  value       = google_compute_instance_template.cc_instance_template.region
}

output "instance_template_project" {
  description = "GCP Project for Compute Instance Template and resource placement"
  value       = google_compute_instance_template.cc_instance_template.project
}

output "cc_instance" {
  description = "CC VM name"
  value       = data.google_compute_instance.cc_vm_instances[*].self_link
}

output "instance_template_forwarding_vpc" {
  description = "GCP VPC for Compute Instance Template VM forwarding interfaces"
  value       = google_compute_instance_template.cc_instance_template.network_interface[0].network
}

output "instance_template_management_vpc" {
  description = "GCP VPC for Compute Instance Template VM management interface"
  value       = google_compute_instance_template.cc_instance_template.network_interface[1].network
}
