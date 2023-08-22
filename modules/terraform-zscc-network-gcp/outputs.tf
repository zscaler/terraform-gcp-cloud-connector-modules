output "mgmt_vpc_network" {
  description = "Cloud Connector Management VPC ID"
  value       = try(google_compute_network.mgmt_vpc_network[0].self_link, data.google_compute_network.mgmt_vpc_network_selected[0].self_link)
}

output "service_vpc_network" {
  description = "Cloud Connector Service VPC ID"
  value       = try(google_compute_network.service_vpc_network[0].self_link, data.google_compute_network.service_vpc_network_selected[0].self_link)
}

output "mgmt_subnet" {
  description = "Subnet for the Cloud Connector Management subnet"
  value       = try(google_compute_subnetwork.mgmt_subnet[0].self_link, data.google_compute_subnetwork.mgmt_subnet_selected[0].self_link)
}

output "service_subnet" {
  description = "Subnet for the Cloud Connector Service subnet"
  value       = try(google_compute_subnetwork.service_subnet[0].self_link, data.google_compute_subnetwork.service_subnet_selected[0].self_link)
}

output "bastion_subnet" {
  description = "Subnet for the bastion host"
  value       = google_compute_subnetwork.mgmt_vpc_subnet_bastion[*].self_link
}

output "workload_subnet" {
  description = "Subnet for the workload host"
  value       = google_compute_subnetwork.vpc_subnet_workload[*].self_link
}

output "mgmt_vpc_nat_gateway" {
  description = "ID of Management VPC NAT Gateway resource"
  value       = try(google_compute_router_nat.mgmt_vpc_nat_gateway[0].id, data.google_compute_router_nat.mgmt_vpc_nat_gateway_selected[0].id)
}

output "service_vpc_nat_gateway" {
  description = "ID of Management VPC NAT Gateway resource"
  value       = try(google_compute_router_nat.service_vpc_nat_gateway[0].id, data.google_compute_router_nat.service_vpc_nat_gateway_selected[0].id)
}
