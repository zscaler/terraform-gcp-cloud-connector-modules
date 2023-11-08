################################################################################
# Generate a unique random string for resource name assignment and key pair
################################################################################
resource "random_string" "suffix" {
  length  = 8
  upper   = false
  special = false
}


################################################################################
# The following lines generates a new SSH key pair and stores the PEM file
# locally. The public key output is used as the ssh_key passed variable
# to the compute modules for admin_ssh_key public_key authentication.
# This is not recommended for production deployments. Please consider modifying
# to pass your own custom public key file located in a secure location.
################################################################################
resource "tls_private_key" "key" {
  algorithm = var.tls_key_algorithm
}

resource "local_file" "private_key" {
  content         = tls_private_key.key.private_key_pem
  filename        = "../${var.name_prefix}-key-${random_string.suffix.result}.pem"
  file_permission = "0600"
}


################################################################################
# 1. Create/reference all network infrastructure resource dependencies for all
#    child modules (vpc, router, nat gateway, subnets)
################################################################################
module "network" {
  source                         = "../../modules/terraform-zscc-network-gcp"
  name_prefix                    = var.name_prefix
  resource_tag                   = random_string.suffix.result
  project                        = coalesce(var.project_host, var.project)
  region                         = var.region
  default_nsg                    = var.default_nsg
  allowed_ssh_from_internal_cidr = [var.subnet_cc_mgmt]
  allowed_ports                  = var.allowed_ports
  subnet_cc_mgmt                 = var.subnet_cc_mgmt
  subnet_cc_service              = var.subnet_cc_service

  byo_vpc              = var.byo_vpc
  byo_mgmt_vpc_name    = var.byo_mgmt_vpc_name
  byo_service_vpc_name = var.byo_service_vpc_name

  byo_subnets             = var.byo_subnets
  byo_mgmt_subnet_name    = var.byo_mgmt_subnet_name
  byo_service_subnet_name = var.byo_service_subnet_name

  byo_router              = var.byo_router
  byo_mgmt_router_name    = var.byo_mgmt_router_name
  byo_service_router_name = var.byo_service_router_name

  byo_natgw              = var.byo_natgw
  byo_mgmt_natgw_name    = var.byo_mgmt_natgw_name
  byo_service_natgw_name = var.byo_service_natgw_name

}

################################################################################
# 2. Create specified number CC VMs per cc_count which will span equally across 
#    designated availability zones per az_count. E.g. cc_count set to 4 and 
#    az_count set to 2 will create 2x CCs in AZ1 and 2x CCs in AZ2
################################################################################
# Create the user_data file with necessary bootstrap variables for Cloud Connector registration
locals {
  userdata = <<USERDATA
{"cc_url": "${var.cc_vm_prov_url}", "secret_name": "${var.secret_name}", "http_probe_port": ${var.http_probe_port}, "lb_vip": "${module.ilb.ilb_ip_address}"}
USERDATA
}

# Write the file to local filesystem for storage/reference
resource "local_file" "user_data_file" {
  content  = local.userdata
  filename = "../user_data"
}


################################################################################
# Locate Latest CC Image
################################################################################
data "google_compute_image" "zs_cc_img" {
  count   = var.image_name != "" ? 0 : 1
  family  = "ZscalerGCPFamily"  #placeholder
  project = "ZscalerGCPProject" #placeholder
}


################################################################################
# Query for active list of available zones for var.region
################################################################################
data "google_compute_zones" "available" {
  status = "UP"
}

locals {
  zones_list = length(var.zones) == 0 ? slice(data.google_compute_zones.available.names, 0, var.az_count) : distinct(var.zones)
}


################################################################################
# Create CC VM instances
################################################################################
module "cc_vm" {
  source                      = "../../modules/terraform-zscc-ccvm-gcp"
  name_prefix                 = var.name_prefix
  resource_tag                = random_string.suffix.result
  project                     = var.project
  region                      = var.region
  zones                       = local.zones_list
  ccvm_instance_type          = var.ccvm_instance_type
  ssh_key                     = tls_private_key.key.public_key_openssh
  user_data                   = local.userdata
  cc_count                    = var.cc_count
  vpc_subnetwork_ccvm_mgmt    = module.network.mgmt_subnet
  vpc_subnetwork_ccvm_service = module.network.service_subnet
  image_name                  = var.image_name != "" ? var.image_name : data.google_compute_image.zs_cc_img[0].self_link
  service_account             = module.iam_service_account.service_account
}


################################################################################
# 3. Create Service Account for all CC VMs
################################################################################
module "iam_service_account" {
  source       = "../../modules/terraform-zscc-iam-service-account-gcp"
  name_prefix  = var.name_prefix
  resource_tag = random_string.suffix.result
  secret_name  = var.secret_name
  project      = var.project
}


################################################################################
# 4. Create ILB
################################################################################
locals {
  instance_groups_list = length(var.zones) == 0 ? slice(module.cc_vm.instance_group_ids, 0, var.az_count) : slice(module.cc_vm.instance_group_ids, 0, length(distinct(var.zones)))
}

module "ilb" {
  source                      = "../../modules/terraform-zscc-ilb-gcp"
  name_prefix                 = var.name_prefix
  resource_tag                = random_string.suffix.result
  vpc_network                 = module.network.service_vpc_network
  project                     = var.project
  project_host                = var.project_host #optional
  region                      = var.region
  instance_groups             = local.instance_groups_list
  vpc_subnetwork_ccvm_service = module.network.service_subnet
  http_probe_port             = var.http_probe_port
  health_check_interval       = var.health_check_interval
  healthy_threshold           = var.healthy_threshold
  unhealthy_threshold         = var.unhealthy_threshold
  session_affinity            = var.session_affinity
  allow_global_access         = var.allow_global_access
}


################################################################################
# 5. Create Cloud DNS Forwarding Zones for ZPA redirection
################################################################################
module "cloud_dns" {
  source         = "../../modules/terraform-zscc-cloud-dns-gcp"
  count          = var.zpa_enabled == true ? 1 : 0
  name_prefix    = var.name_prefix
  resource_tag   = random_string.suffix.result
  vpc_networks   = [module.network.service_vpc_network]
  domain_names   = var.domain_names
  target_address = [module.ilb.ilb_ip_address]
  project        = var.project
  project_host   = var.project_host #optional
}
