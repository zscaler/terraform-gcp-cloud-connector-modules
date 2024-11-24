################################################################################
# Create VPC Network, Subnet, Router, and NAT Gateway for Cloud Connector 
# Management Interface
################################################################################
resource "google_compute_network" "mgmt_vpc_network" {
  count                   = var.byo_vpc == false ? 1 : 0
  name                    = "${var.name_prefix}-mgmt-vpc-${var.resource_tag}"
  auto_create_subnetworks = false
  routing_mode            = var.routing_mode
  project                 = var.project
}

# Or reference an existing VPC
data "google_compute_network" "mgmt_vpc_network_selected" {
  count = var.byo_vpc ? 1 : 0
  name  = var.byo_mgmt_vpc_name
}

################################################################################
# Create CC Management VPC Subnet
################################################################################
resource "google_compute_subnetwork" "mgmt_subnet" {
  count         = var.byo_subnets == false ? 1 : 0
  name          = "${var.name_prefix}-mgmt-subnet-${var.resource_tag}"
  ip_cidr_range = var.subnet_cc_mgmt
  network       = try(google_compute_network.mgmt_vpc_network[0].self_link, data.google_compute_network.mgmt_vpc_network_selected[0].self_link)
  region        = var.region
}

# Or reference an existing subnet
data "google_compute_subnetwork" "mgmt_subnet_selected" {
  count  = var.byo_subnets ? 1 : 0
  name   = var.byo_mgmt_subnet_name
  region = var.region
}

################################################################################
# Create CC Management VPC Router
################################################################################
resource "google_compute_router" "mgmt_vpc_router" {
  count   = var.byo_router == false ? 1 : 0
  name    = "${var.name_prefix}-mgmt-vpc-router-${var.resource_tag}"
  network = try(google_compute_network.mgmt_vpc_network[0].self_link, data.google_compute_network.mgmt_vpc_network_selected[0].self_link)
}

# Or reference an existing router
data "google_compute_router" "mgmt_vpc_router_selected" {
  count   = var.byo_router ? 1 : 0
  name    = var.byo_mgmt_router_name
  network = var.byo_mgmt_vpc_name
}

################################################################################
# Create CC Management VPC NAT Gateway
################################################################################
resource "google_compute_router_nat" "mgmt_vpc_nat_gateway" {
  count                              = var.byo_natgw == false ? 1 : 0
  name                               = "${var.name_prefix}-mgmt-vpc-nat-gw-${var.resource_tag}"
  router                             = try(data.google_compute_router.mgmt_vpc_router_selected[0].name, google_compute_router.mgmt_vpc_router[0].name)
  region                             = try(data.google_compute_router.mgmt_vpc_router_selected[0].region, google_compute_router.mgmt_vpc_router[0].region)
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Or reference an existing NAT Gateway
data "google_compute_router_nat" "mgmt_vpc_nat_gateway_selected" {
  count  = var.byo_natgw ? 1 : 0
  name   = var.byo_mgmt_natgw_name
  router = var.byo_mgmt_router_name
}


################################################################################
# Create VPC Network, Subnet, Router, and NAT Gateway for Cloud Connector 
# Service Interfaces
################################################################################
resource "google_compute_network" "service_vpc_network" {
  count                   = var.byo_vpc == false ? 1 : 0
  name                    = "${var.name_prefix}-service-vpc-${var.resource_tag}"
  auto_create_subnetworks = false
  routing_mode            = var.routing_mode
}

# Or reference an existing VPC
data "google_compute_network" "service_vpc_network_selected" {
  count = var.byo_vpc ? 1 : 0
  name  = var.byo_service_vpc_name
}

################################################################################
# Create CC Service VPC Subnet
################################################################################
resource "google_compute_subnetwork" "service_subnet" {
  count         = var.byo_subnets == false ? 1 : 0
  name          = "${var.name_prefix}-service-subnet-${var.resource_tag}"
  ip_cidr_range = var.subnet_cc_service
  network       = try(google_compute_network.service_vpc_network[0].self_link, data.google_compute_network.service_vpc_network_selected[0].self_link)
  region        = var.region
}

# Or reference an existing subnet
data "google_compute_subnetwork" "service_subnet_selected" {
  count  = var.byo_subnets ? 1 : 0
  name   = var.byo_service_subnet_name
  region = var.region
}

################################################################################
# Create CC Service VPC Router
################################################################################
resource "google_compute_router" "service_vpc_router" {
  count   = var.byo_router == false ? 1 : 0
  name    = "${var.name_prefix}-service-vpc-router-${var.resource_tag}"
  network = try(google_compute_network.service_vpc_network[0].self_link, data.google_compute_network.service_vpc_network_selected[0].self_link)
}

# Or reference an existing router
data "google_compute_router" "service_vpc_router_selected" {
  count   = var.byo_router ? 1 : 0
  name    = var.byo_service_router_name
  network = var.byo_service_vpc_name
}

################################################################################
# Create CC Service VPC NAT Gateway
################################################################################
resource "google_compute_router_nat" "service_vpc_nat_gateway" {
  count                              = var.byo_natgw == false ? 1 : 0
  name                               = "${var.name_prefix}-service-vpc-nat-gw-${var.resource_tag}"
  router                             = try(data.google_compute_router.service_vpc_router_selected[0].name, google_compute_router.service_vpc_router[0].name)
  region                             = try(data.google_compute_router.service_vpc_router_selected[0].region, google_compute_router.service_vpc_router[0].region)
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Or reference an existing NAT Gateway
data "google_compute_router_nat" "service_vpc_nat_gateway_selected" {
  count  = var.byo_natgw ? 1 : 0
  name   = var.byo_service_natgw_name
  router = var.byo_service_router_name
}


################################################################################
# Create subnet for bastion jump host (if enabled) in the Management VPC
################################################################################
resource "google_compute_subnetwork" "mgmt_vpc_subnet_bastion" {
  count         = var.bastion_enabled ? 1 : 0
  name          = "${var.name_prefix}-vpc-subnet-bastion-${var.resource_tag}"
  ip_cidr_range = var.subnet_bastion
  network       = google_compute_network.mgmt_vpc_network[0].self_link
  region        = var.region
}


################################################################################
# Create subnet for client workloads (if enabled) in Service VPC
################################################################################
resource "google_compute_subnetwork" "vpc_subnet_workload" {
  count         = var.workloads_enabled ? 1 : 0
  name          = "${var.name_prefix}-vpc-subnet-workload-${var.resource_tag}"
  ip_cidr_range = var.subnet_workload
  network       = google_compute_network.service_vpc_network[0].self_link
  region        = var.region
}


################################################################################
# Create vpc peering between Management and Service VPC
# Only required for base (greenfield) deployment templates for bastion host
# to be able CC management interfaces and workloads in service VPC
################################################################################
resource "google_compute_network_peering" "management_to_service" {
  count        = var.workloads_enabled ? 1 : 0
  name         = "${var.name_prefix}-vpc-peer-mgmt-to-service-${var.resource_tag}"
  network      = google_compute_network.mgmt_vpc_network[0].self_link
  peer_network = google_compute_network.service_vpc_network[0].self_link

  import_custom_routes = true
  export_custom_routes = true
}

resource "google_compute_network_peering" "service_to_management" {
  count        = var.workloads_enabled ? 1 : 0
  name         = "${var.name_prefix}-vpc-peer-service-to-mgmt-${var.resource_tag}"
  network      = google_compute_network.service_vpc_network[0].self_link
  peer_network = google_compute_network.mgmt_vpc_network[0].self_link

  import_custom_routes = true
  export_custom_routes = true
}


################################################################################
# Create pre-defined GCP Security Groups and rules for Cloud Connector
################################################################################
resource "google_compute_firewall" "ssh_intranet_cc_mgmt" {
  name        = coalesce(var.fw_cc_mgmt_ssh_ingress_name, "${var.name_prefix}-fw-ssh-for-mgmt-${var.resource_tag}")
  description = "Permit SSH inboud access to Cloud Connector Management VPC"
  network     = try(google_compute_network.mgmt_vpc_network[0].self_link, data.google_compute_network.mgmt_vpc_network_selected[0].self_link)
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = var.allowed_ssh_from_internal_cidr
}

resource "google_compute_firewall" "zssupport_tunnel_cc_mgmt" {
  count       = var.support_access_enabled ? 1 : 0
  name        = coalesce(var.fw_cc_mgmt_zssupport_tunnel_name, "${var.name_prefix}-zscaler-support-access-${var.resource_tag}")
  description = "Required for Cloud Connector to establish connectivity for Zscaler Support to remotely assist"
  network     = try(google_compute_network.mgmt_vpc_network[0].self_link, data.google_compute_network.mgmt_vpc_network_selected[0].self_link)
  direction   = "EGRESS"
  allow {
    protocol = "tcp"
    ports    = ["12002"]
  }
  destination_ranges = ["199.168.148.101/32"]
}

resource "google_compute_firewall" "hcp_vault_cc_mgmt" {
  count       = var.hcp_vault_enabled ? 1 : 0
  name        = coalesce(var.fw_cc_mgmt_hcp_vault_address_name, "${var.name_prefix}-hcp-vault-addr-access-${var.resource_tag}")
  description = "Optional output rule for HCP Vault address connectivity"
  network     = try(google_compute_network.mgmt_vpc_network[0].self_link, data.google_compute_network.mgmt_vpc_network_selected[0].self_link)
  direction   = "EGRESS"
  allow {
    protocol = "tcp"
    ports    = [var.hcp_vault_port]
  }
  destination_ranges = var.hcp_vault_ips
}

resource "google_compute_firewall" "default_service" {
  name        = coalesce(var.fw_cc_service_default_name, "${var.name_prefix}-fw-default-for-service-${var.resource_tag}")
  description = "Default rule permitting workload traffic forwarded into Cloud Connector service network interfaces"
  network     = try(google_compute_network.service_vpc_network[0].self_link, data.google_compute_network.service_vpc_network_selected[0].self_link)
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = var.allowed_ports
  }
  allow {
    protocol = "udp"
    ports    = var.allowed_ports
  }
  source_ranges = var.default_nsg
}
