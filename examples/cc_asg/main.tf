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

  hcp_vault_enabled = var.hcp_vault_enabled
  hcp_vault_ips     = var.hcp_vault_ips
  hcp_vault_port    = var.hcp_vault_port

  subnet_cc_mgmt         = var.subnet_cc_mgmt
  subnet_cc_service      = var.subnet_cc_service
  support_access_enabled = var.support_access_enabled

  ## Optional: Custom Firewall Rule Names. If not specified and conditions are met for rule
  ##           creation, then names will be auto generated with pre-defined values
  fw_cc_mgmt_ssh_ingress_name       = var.fw_cc_mgmt_ssh_ingress_name
  fw_cc_service_default_name        = var.fw_cc_service_default_name
  fw_cc_mgmt_zssupport_tunnel_name  = var.fw_cc_mgmt_zssupport_tunnel_name
  fw_cc_mgmt_hcp_vault_address_name = var.fw_cc_mgmt_hcp_vault_address_name

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
  # Populate potential locals map with HCP Vault variables
  hcpuserdata = <<USERDATA
{
  "cc_url": "${var.cc_vm_prov_url}",
  "http_probe_port": ${var.http_probe_port},
  "hcp_vault_addr": "${var.hcp_vault_address}",
  "hcp_vault_secret_path": "${var.hcp_vault_secret_path}",
  "hcp_vault_role_name": "${var.hcp_vault_role_name}",
  "hcp_gcp_auth_role_type": "${var.hcp_gcp_auth_role_type}",
  "gcp_service_account": "${module.iam_service_account.service_account}",
  "lb_vip": "${module.ilb.ilb_ip_address}"
}
USERDATA

  # Populate potential local map with default GCP Secret Manager
  userdata = <<USERDATA
{
  "cc_url": "${var.cc_vm_prov_url}",
  "secret_name": "${var.secret_name}",
  "http_probe_port": ${var.http_probe_port},
  "gcp_service_account": "${module.iam_service_account.service_account}",
  "lb_vip": "${module.ilb.ilb_ip_address}"
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
  vpc_subnetwork_ccvm_mgmt    = module.network.mgmt_subnet
  vpc_subnetwork_ccvm_service = module.network.service_subnet
  image_name                  = var.image_name != "" ? var.image_name : data.google_compute_image.zs_cc_img[0].self_link
  service_account             = module.iam_service_account.service_account
  autoscaling_enabled         = var.autoscaling_enabled
  max_replicas                = var.max_replicas
  min_replicas                = var.min_replicas
  cooldown_period             = var.cooldown_period
  target_cpu_util_value       = var.target_cpu_util_value

  ## Optional: Custom instance names. If not specified and conditions are met for resource
  ##           creation, then names will be auto generated with pre-defined values
  instance_template_name_prefix = var.instance_template_name_prefix
  instance_template_name        = var.instance_template_name
  instance_group_name           = var.instance_group_name
  base_instance_name            = var.base_instance_name
  autoscaling_name              = var.autoscaling_name
}


################################################################################
# 3. Create Service Account for all CC VMs
################################################################################
module "iam_service_account" {
  source                   = "../../modules/terraform-zscc-iam-service-account-gcp"
  project                  = var.project
  byo_ccvm_service_account = var.byo_ccvm_service_account
  ## If byo_ccvm_service_account is provided any non-empty value, all variables below will be
  ## ignored/unused. Script assumes that role permissions for either Secret Manager
  ## (roles/secretmanager.secretAccessor) or HCP Vault (roles/iam.serviceAccountTokenCreator)
  ## already exists
  secret_name         = var.secret_name
  hcp_vault_enabled   = var.hcp_vault_enabled
  autoscaling_enabled = var.autoscaling_enabled
  ## Optional: Custom Service Account names. If not specified and conditions are met for resource
  ##           creation, then names will be auto generated with pre-defined values
  service_account_id           = coalesce(var.service_account_id, "${var.name_prefix}-ccvm-sa-${random_string.suffix.result}")
  service_account_display_name = coalesce(var.service_account_display_name, "${var.name_prefix}-ccvm-sa-${random_string.suffix.result}")
}


################################################################################
# 4. Create ILB
################################################################################
locals {
  instance_groups_id_list = length(var.zones) == 0 ? slice(module.cc_vm.instance_group_ids, 0, var.az_count) : slice(module.cc_vm.instance_group_ids, 0, length(distinct(var.zones)))
}

module "ilb" {
  source                      = "../../modules/terraform-zscc-ilb-gcp"
  vpc_network                 = module.network.service_vpc_network
  project                     = var.project
  project_host                = var.project_host #optional
  region                      = var.region
  instance_groups             = local.instance_groups_id_list
  vpc_subnetwork_ccvm_service = module.network.service_subnet
  http_probe_port             = var.http_probe_port
  health_check_interval       = var.health_check_interval
  healthy_threshold           = var.healthy_threshold
  unhealthy_threshold         = var.unhealthy_threshold
  session_affinity            = var.session_affinity
  allow_global_access         = var.allow_global_access

  ilb_backend_service_name = coalesce(var.ilb_backend_service_name, "${var.name_prefix}-udp-backend-service-${random_string.suffix.result}")
  ilb_health_check_name    = coalesce(var.ilb_health_check_name, "${var.name_prefix}-cc-health-check-${random_string.suffix.result}")
  ilb_frontend_ip_name     = coalesce(var.ilb_frontend_ip_name, "${var.name_prefix}-ilb-ip-address-${random_string.suffix.result}")
  ilb_forwarding_rule_name = coalesce(var.ilb_forwarding_rule_name, "${var.name_prefix}-forwarding-rule-${random_string.suffix.result}")
  fw_ilb_health_check_name = coalesce(var.fw_ilb_health_check_name, "${var.name_prefix}-allow-cc-health-check-${random_string.suffix.result}")
}


################################################################################
# 5. Cloud Run Function
################################################################################
locals {
  instance_groups_name_list = length(var.zones) == 0 ? slice(module.cc_vm.instance_group_names, 0, var.az_count) : slice(module.cc_vm.instance_group_names, 0, length(distinct(var.zones)))
}

module "cc_cloud_function" {
  source                                    = "../../modules/terraform-zscc-cloud-function-gcp"
  name_prefix                               = var.name_prefix
  resource_tag                              = random_string.suffix.result
  project                                   = coalesce(var.project_host, var.project)
  region                                    = var.region
  runtime                                   = var.runtime
  enable_scheduler                          = var.enable_scheduler
  missing_metrics_warning_threshold_min     = var.missing_metrics_warning_threshold_min
  missing_metrics_critical_threshold_min    = var.missing_metrics_critical_threshold_min
  missing_metrics_termination_threshold_min = var.missing_metrics_termination_threshold_min
  data_points_eval_period                   = var.data_points_eval_period
  unhealthy_metric_threshold                = var.unhealthy_metric_threshold
  consecutive_unhealthy_threshold           = var.consecutive_unhealthy_threshold
  zscaler_user_agent                        = var.zscaler_user_agent

  byo_storage_bucket      = var.byo_storage_bucket
  storage_bucket_location = var.storage_bucket_location
  storage_bucket_name     = var.storage_bucket_name != "" ? var.storage_bucket_name : "${var.name_prefix}-cc-function-bucket-${random_string.suffix.result}"

  cloud_function_source_object_name = var.cloud_function_source_object_name
  upload_cloud_function_zip         = var.upload_cloud_function_zip
  cloud_function_source_object_path = var.cloud_function_source_object_path

  byo_function_service_account = var.byo_function_service_account
  ## If byo_function_service_account is provided any non-empty value, all variables below will be
  ## ignored/unused. Script assumes that role permissions for either Secret Manager
  ## (roles/secretmanager.secretAccessor) or HCP Vault (roles/iam.serviceAccountTokenCreator)
  ## already exists

  ## Optional: Custom Service Account names. If not specified and conditions are met for resource
  ##           creation, then names will be auto generated with pre-defined values
  cloud_function_service_account_id           = coalesce(var.cloud_function_service_account_id, "${var.name_prefix}-function-sa-${random_string.suffix.result}")
  cloud_function_service_account_display_name = coalesce(var.cloud_function_service_account_display_name, "${var.name_prefix}-function-sa-${random_string.suffix.result}")

  #required environment variable inputs
  cc_vm_prov_url             = var.cc_vm_prov_url
  sync_dry_run               = var.sync_dry_run
  sync_max_deletions_per_run = var.sync_max_deletions_per_run
  sync_excluded_instances    = var.sync_excluded_instances
  instance_group_names       = local.instance_groups_name_list

  #Secret storage - either GCP Secrets Manager 
  secret_name = var.secret_name
  #Or Hashicorp Vault
  hcp_vault_enabled      = var.hcp_vault_enabled
  hcp_vault_address      = var.hcp_vault_address
  hcp_vault_secret_path  = var.hcp_vault_secret_path
  hcp_vault_role_name    = var.hcp_vault_role_name
  hcp_gcp_auth_role_type = var.hcp_gcp_auth_role_type
}


################################################################################
# 6. Create Cloud DNS Forwarding Zones for ZPA redirection if enabled
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
