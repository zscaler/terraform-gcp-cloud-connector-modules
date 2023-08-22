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
  project                        = var.project
  region                         = var.region
  default_nsg                    = var.default_nsg
  allowed_ssh_from_internal_cidr = [var.subnet_cc_mgmt, var.subnet_bastion]
  allowed_ports                  = var.allowed_ports

  subnet_workload   = var.subnet_workload
  subnet_bastion    = var.subnet_bastion
  subnet_cc_mgmt    = var.subnet_cc_mgmt
  subnet_cc_service = var.subnet_cc_service

  workloads_enabled = true
  bastion_enabled   = true
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
  name_prefix                    = var.name_prefix
  resource_tag                   = random_string.suffix.result
  subnet                         = module.network.workload_subnet[0]
  zone                           = length(var.zones) == 0 ? data.google_compute_zones.available.names[0] : var.zones[0]
  ssh_key                        = tls_private_key.key.public_key_openssh
  vpc_network                    = module.network.service_vpc_network
  allowed_ssh_from_internal_cidr = [var.subnet_cc_mgmt, var.subnet_bastion]
}

resource "google_compute_route" "route_to_cc_vm" {
  name              = "${var.name_prefix}-route-to-cc-vm-${random_string.suffix.result}"
  dest_range        = "0.0.0.0/0"
  priority          = 600
  network           = module.network.service_vpc_network
  tags              = [module.workload.network_tag]
  next_hop_instance = module.cc_vm.cc_instance[0]
}


################################################################################
# 4. Create specified number CC VMs per cc_count which will span equally across 
#    designated availability zones per az_count. E.g. cc_count set to 4 and 
#    az_count set to 2 will create 2x CCs in AZ1 and 2x CCs in AZ2
################################################################################
# Create the user_data file with necessary bootstrap variables for Cloud Connector registration
locals {
  userdata = <<USERDATA
{"cc_url": "${var.cc_vm_prov_url}", "secret_name": "${var.secret_name}", "http_probe_port": ${var.http_probe_port}}
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
# 5. Create Service Account for all CC VMs
################################################################################
module "iam_service_account" {
  source       = "../../modules/terraform-zscc-iam-service-account-gcp"
  name_prefix  = var.name_prefix
  resource_tag = random_string.suffix.result
  secret_name  = var.secret_name
}
