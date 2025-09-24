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
  allowed_ssh_from_internal_cidr = [var.subnet_cc_mgmt, var.subnet_bastion]
  allowed_ports                  = var.allowed_ports

  hcp_vault_enabled = var.hcp_vault_enabled
  hcp_vault_ips     = var.hcp_vault_ips
  hcp_vault_port    = var.hcp_vault_port

  subnet_workload   = var.subnet_workload
  subnet_bastion    = var.subnet_bastion
  subnet_cc_mgmt    = var.subnet_cc_mgmt
  subnet_cc_service = var.subnet_cc_service

  workloads_enabled      = true
  bastion_enabled        = true
  support_access_enabled = var.support_access_enabled

  ## Optional: Custom Firewall Rule Names. If not specified and conditions are met for rule
  ##           creation, then names will be auto generated with pre-defined values
  fw_cc_mgmt_ssh_ingress_name       = var.fw_cc_mgmt_ssh_ingress_name
  fw_cc_service_default_name        = var.fw_cc_service_default_name
  fw_cc_mgmt_zssupport_tunnel_name  = var.fw_cc_mgmt_zssupport_tunnel_name
  fw_cc_mgmt_hcp_vault_address_name = var.fw_cc_mgmt_hcp_vault_address_name
}


################################################################################
# 2. Create Bastion Host for CC VM SSH jump access
################################################################################
module "bastion" {
  source               = "../../modules/terraform-zscc-bastion-gcp"
  name_prefix          = var.name_prefix
  resource_tag         = random_string.suffix.result
  public_subnet        = module.network.bastion_subnet[0]
  zone                 = length(var.zones) == 0 ? data.google_compute_zones.available.names[0] : var.zones[0]
  ssh_key              = tls_private_key.key.public_key_openssh
  vpc_network          = module.network.mgmt_vpc_network
  bastion_ssh_allow_ip = var.bastion_ssh_allow_ip
}


################################################################################
# 3. Create Workload Hosts to test traffic connectivity through CC
################################################################################
module "workload" {
  source                         = "../../modules/terraform-zscc-workload-gcp"
  workload_count                 = var.workload_count
  name_prefix                    = var.name_prefix
  resource_tag                   = random_string.suffix.result
  subnet                         = module.network.workload_subnet[0]
  zones                          = local.zones_list
  ssh_key                        = tls_private_key.key.public_key_openssh
  vpc_network                    = module.network.service_vpc_network
  allowed_ssh_from_internal_cidr = [var.subnet_cc_mgmt, var.subnet_bastion]
}

resource "google_compute_route" "route_to_cc_vm" {
  name              = "${var.name_prefix}-route-to-cc-vm-${random_string.suffix.result}"
  dest_range        = "0.0.0.0/0"
  priority          = 600
  network           = module.network.service_vpc_network
  tags              = module.workload.workload_network_tag
  next_hop_instance = module.cc_vm.cc_instance[0]
}


################################################################################
# 4. Create specified number CC VMs per cc_count which will span equally across 
#    designated availability zones per az_count. E.g. cc_count set to 4 and 
#    az_count set to 2 will create 2x CCs in AZ1 and 2x CCs in AZ2
################################################################################
# Create the user_data file with necessary bootstrap variables for Cloud Connector registration
locals {
  # Populate potential locals map with HCP Vault variables
  hcpuserdata = <<USERDATA
{
  "cc_url": "${var.cc_vm_prov_url}",
  "http_probe_port": ${var.http_probe_port},
  "hcp_vault_addr": "${var.hcp_vault_address}",
  "hcp_vault_secret_path": "${var.hcp_vault_secret_path}",
  "hcp_vault_role_name": "${var.hcp_vault_role_name}",
  "hcp_gcp_auth_role_type": "${var.hcp_gcp_auth_role_type}",
  "gcp_service_account": "${module.iam_service_account.service_account}"
}
USERDATA

  # Populate potential local map with default GCP Secret Manager
  userdata = <<USERDATA
{
  "cc_url": "${var.cc_vm_prov_url}", 
  "secret_name": "${var.secret_name}", 
  "http_probe_port": ${var.http_probe_port},
  "gcp_service_account": "${module.iam_service_account.service_account}"
}
USERDATA

  # if hcp_vault_enabled is true use hcpuserdata; else use standard userdata
  userdata_selected = var.hcp_vault_enabled ? local.hcpuserdata : local.userdata
}


# Write the file to local filesystem for storage/reference. Use HCP Vault locals if values exist, else fall back to GCP Secrets Manager
resource "local_file" "user_data_file" {
  content  = local.userdata_selected
  filename = "../user_data"
}



################################################################################
# Locate Latest CC Image
################################################################################
data "google_compute_image" "zs_cc_img" {
  count   = var.image_name != "" ? 0 : 1
  project = "mpi-zscalercloudconnector-publ"
  name    = "zs-cc-ga-02022025"
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
  user_data                   = local.userdata_selected
  cc_count                    = var.cc_count
  vpc_subnetwork_ccvm_mgmt    = module.network.mgmt_subnet
  vpc_subnetwork_ccvm_service = module.network.service_subnet
  image_name                  = var.image_name != "" ? var.image_name : data.google_compute_image.zs_cc_img[0].self_link
  service_account             = module.iam_service_account.service_account

  ## Optional: Custom instance names. If not specified and conditions are met for resource
  ##           creation, then names will be auto generated with pre-defined values
  instance_template_name_prefix = var.instance_template_name_prefix
  instance_template_name        = var.instance_template_name
  instance_group_name           = var.instance_group_name
  base_instance_name            = var.base_instance_name

}


################################################################################
# 5. Create Service Account for all CC VMs
################################################################################
module "iam_service_account" {
  source                   = "../../modules/terraform-zscc-iam-service-account-gcp"
  project                  = var.project
  grant_pubsub_editor      = true
  byo_ccvm_service_account = var.byo_ccvm_service_account
  ## If byo_ccvm_service_account is provided any non-empty value, all variables below will be
  ## ignored/unused. Script assumes that role permissions for either Secret Manager
  ## (roles/secretmanager.secretAccessor) or HCP Vault (roles/iam.serviceAccountTokenCreator)
  ## already exists
  secret_name       = var.secret_name
  hcp_vault_enabled = var.hcp_vault_enabled
  ## Optional: Custom Service Account names. If not specified and conditions are met for resource
  ##           creation, then names will be auto generated with pre-defined values
  service_account_id           = coalesce(var.service_account_id, "${var.name_prefix}-ccvm-sa-${random_string.suffix.result}")
  service_account_display_name = coalesce(var.service_account_display_name, "${var.name_prefix}-ccvm-sa-${random_string.suffix.result}")
}
