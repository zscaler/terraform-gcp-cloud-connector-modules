## This is only a sample terraform.tfvars file.
## Uncomment and change the below variables according to your specific environment

#####################################################################################################################
##### Variables are populated automically if terraform is ran via ZSEC bash script.   ##### 
##### Modifying the variables in this file will override any inputs from ZSEC         #####
#####################################################################################################################


#####################################################################################################################
##### Terraform/Cloud Environment variables  #####
#####################################################################################################################

## 1. GCP region where Cloud Connector resources will be deployed. This environment variable is automatically populated if running ZSEC script
##    and thus will override any value set here. Only uncomment and set this value if you are deploying terraform standalone.

#region                                     = "us-central1"

## 2. Path relative to terraform root directory where the service account json file exists for terraform to authenticate to Google Cloud

#credentials                                = "/tmp/cc-tf-service-account.json"

## 3. GCP Project ID to deploy/reference resources created

#project                                    = "cc-host-project"


#####################################################################################################################
##### Cloud Init Userdata Provisioning variables  #####
#####################################################################################################################

## 4. Zscaler Cloud Connector Provisioning URL E.g. connector.zscaler.net/api/v1/provUrl?name=gcp_prov_url

#cc_vm_prov_url                             = "connector.zscaler.net/api/v1/provUrl?name=gcp_prov_url"

## 5. Secrets Vault Configuration:
##    Zscaler support storing Cloud Connector secrets in either GCP Secret Manager OR HashiCorp Vault.
##    Uncomment and enter required information for one or the other. Terraform uses this information to populate VM userdata 

## Option A. GCP Secrets Manager Secret ID/Resoure Name from Secrets Manager E.g projects/1234567890123/secrets/secret_name

#secret_name                                =  "projects/1234567890123/secrets/secret_name"

## Option B. HashiCorp (HCP) Vault information. Uncomment and supply all variables formatted as th examples below
##           When set to true, the hcp_vault_enabled variable serves three functions.
##           1. Select the correct userdata locals generation
##           2. Add role iam.serviceAccountTokenCreator to the Service Account (assuming script is creating that as well)
##           3. Add CC VPC firewall rule ensuring access permitted to the vault address + port

#hcp_vault_enabled                          = true
#hcp_vault_address                          = "https://vault-cluster-public-vault-7cad09f8.c48690b5.z1.hashicorp.cloud:8200"
#hcp_vault_secret_path                      = "/v1/admin/secret/data/zsb-11584294-cc"
#hcp_vault_role_name                        = "vault-iam-auth-role"
#hcp_gcp_auth_role_type                     = "gcp_iam"

## 6. Cloud Connector HTTP listener port. This is required for ILB deployment health checks. 
## Uncomment and set custom probe port to a single value of 80 or any number between 1024-65535. Default is 50000.

#http_probe_port                            = 50000


#####################################################################################################################
##### Custom variables. Only change if required for your environment  #####
#####################################################################################################################

## 7. The name string for all Cloud Connector resources created by Terraform for Tag/Name attributes. (Default: zscc)
##    Due to GCP character constraints, there are validations where this value must be 12 or less characters and only
##    lower case.

#name_prefix                                = "zscc"

## 8. Cloud Connector GCP Compute Instance size selection. Uncomment ccvm_instance_type line with desired vm size to change.
##    (Default: n2-standard-2)

#ccvm_instance_type                         = "n2-standard-2"
#ccvm_instance_type                         = "e2-standard-2"
#ccvm_instance_type                         = "n2d-standard-2"

## 9. Network Configuration:
##    Subnet space. (Minimum /28 required. Uncomment and modify if byo_vpc is set to true but byo_subnets is left false meaning you want terraform to create 
##    NEW subnets in those existing VPCs.

#subnet_cc_mgmt                             = "10.0.1.0/24"
#subnet_cc_service                          = "10.1.1.0/24"

## 10. Availabilty Zone resiliency configuration:

## Option A. By default, Terraform will perform a lookup on the region being deployed for what/how many availability zones are currently available for use.
##           Based on this output, we will take the first X number of available zones per az_count and create Compute Instance Groups in in each. Available 
##           input range 1-3 (Default: 1) 

## Example: Region is us-central1 with az_count set to 2. Terraform will create 1 Instance Group in us-central1-a and 1x Instance Group in us-central1-b
##          (or whatever first two zones report back as available) each with their own Autoscaler Policy. 

#az_count                                   = 2

## Option B. If you require Instance Groups to be set explicitly in certain availability zones, you can override the region lookup and set the zones.

## Note: By setting zone names here, Terraform will ignore any value set for variable az_count. We also cannot verify the availability correct naming syntax
##       of the names set.

#zones                                      = ["us-central1-a","us-central1-b"]

## 11. The minimum number of Cloud Connectors to maintain per Instance Group/Availability Zone.
##     Recommendation is to maintain HA/Zonal resiliency so for example if az_count = 2 or zones specified = 2 then the minimum number of CCs you would want for a
##     production deployment would be 2 (one in each zone).
##     E.g. min_replicas set to 2 and var.az_count or var.zones set to 2 will create 2x Zonal Instance Groups with at least 2x target CCs in each Instance Group

#min_replicas                               = 2

## 12. The maximum number of Cloud Connectors to maintain in an Autoscaling group. (Default: 4)
##     Value must be a number between 1 and 10

#max_replicas                               = 4

## 13. The number of seconds that the autoscaler should wait before it starts collecting information from a new instance. 
##.    This prevents the autoscaler from collecting information when the instance is initializing, during which the collected usage would not be reliable

#cooldown_period                           = 900

## 14. Target value number for autoscaling policy CPU utilization target tracking. ie: trigger a scale in/out to keep average CPU Utliization percentage across all instances at/under this number
##     (Default: 70%)

#target_cpu_util_value                      = 70

## 15. Custom image name to used for deploying Cloud Connector appliances. By default, Terraform will lookup the latest image version from the Google Marketplace.
##     This variable is provided if a customer desires to override/retain a specific image name/Instance Template version

## Note: It is NOT RECOMMENDED to statically set CC image versions. Zscaler recommends always running/deploying the latest version template

#image_name                                 = "zs-image-gcp-20230928152536-la-1"

## 16. By default, if Terraform is creating an outbound VPC firewall rule named zscaler_support_access enabling 
##     Zscaler remote support access. Without this firewall access, Zscaler Support may not be able to assist as
##     efficiently if troubleshooting is required. Uncomment if you do not want to enable this rule. 
##
##     For more information, refer to: https://config.zscaler.com/zscaler.net/cloud-branch-connector and 
##     https://help.zscaler.com/cloud-branch-connector/enabling-remote-access

#support_access_enabled                     = false

## 17. If byo_ccvm_service_account is provided any non-empty value, no IAM Role creations are executed.
##     terraform-zscc-iam-service-account-gcp module assumes that role permissions for either Secret Manager
##     (roles/secretmanager.secretAccessor) or HCP Vault (roles/iam.serviceAccountTokenCreator)
##     already exists. Uncomment and provide existing service account only if prerequisite permissions are met.

#byo_ccvm_service_account                   = "service-account-id"


#####################################################################################################################
##### Cloud Run Function specific autoscaler variables  #####
#####################################################################################################################

## 18. Enable/Disable the use of a Cloud Scheduler job to trigger both Cloud Run Functions (Health Monitor and Resource Sync)
##     (Recommended Default: true)

#enable_scheduler                           = true

## 19. By default, this template will create a new Storage Bucket for Autoscaling Cloud Run Function"
##     Uncomment to set to True if you want to use an existing Storage Bucket to associate with the Cloud Run Function

#byo_storage_bucket                         = true

## 20. Storage Bucket parameters:

##     Required if var.byo_storage_bucket is true. 
##     Optional if var.byo_storage_bucket is false as this script will automatically create unique name with Storage Bucket creation
##     Uncomment to set the existing storage bucket name OR to override the automatically generated name

#storage_bucket_name                        = "existing-bucket-name"

##     Optional if var.byo_storage_bucket is true. Location for the Storage Bucket. Must be a multi-region or dual-region location. See https://cloud.google.com/storage/docs/locations for more details"
##     Uncomment to set the location to a different geo-region

#storage_bucket_location                    = "US"

## 21. By default, this template will create a new, dedicated Service Account for the Cloud Run Functions with all required IAM Policy permissions
##     If byo_function_service_account is provided any non-empty value, no IAM Role creations are executed
##     Uncomment to set to True if you want to use an existing Service Account to associate with the Cloud Run Function only if prerequisite permissions are met

##    Prerequisite permissions for existing service account:
##    - roles/compute.instanceAdmin.v1
##    - roles/monitoring.viewer
##    - roles/logging.logWriter
##    - roles/cloudfunctions.invoker
##    - roles/secretmanager.secretAccessor << scoped to the secrets manager secret ID per var.secret_name

#byo_function_service_account               = true

## 22. By default, the Cloud Run Function module do perform the following tasks:
##     1. Create a new Storage Bucket
##     2. Look for a local zip file of the Cloud Run Function code in the root (e.g. base_cc_asg) function_zip/ directory with the name matching var.cloud_function_source_object_name
##.       ie: var.cloud_function_source_object_path
##     3. Upload that zip file to that storage bucket as a new object

##     Uncomment to set to False to prevent creation/upload of the bucket object (Not recommended)
##     **NOTE** The Cloud Run Function is REQUIRED for a fully functioning Autoscaling Cloud Connector deployment,
##              so this option should only be set if you have an existing storage bucket where this zip file also already exists

#upload_cloud_function_zip                  = false 

## 23. For successful Cloud Run Function resource creation, we require access to a storage bucket and the specified object name
##     where the Cloud Run Function code zip file is located. By default, the expected object name is "cloud-functions-latest.zip"
##     Uncomment to set a different object name if needed for upload or reference (if upload_cloud_function_zip is set to false)

#cloud_function_source_object_name          = "cloud-functions-latest.zip"

## 24. Only required if variable upload_cloud_function_ip is set to true. This must contain the full, local path + file name (matching var.cloud_function_source_object_name)
##     that will be referenced as the source to upload the zip file to the specified GCP Storage Bucket"

#cloud_function_source_object_path          = "./function_zip/cloud-functions-latest.zip"


#####################################################################################################################
##### ZPA/Google Cloud Private DNS specific variables #####
#####################################################################################################################
## 25. By default, ZPA dependent resources are not created. Uncomment if you want to enable ZPA configuration in your VPC

#zpa_enabled                                = true

## 26. Provide the domain names you want Google Cloud DNS to redirect to Cloud Connector for ZPA interception. 
##     Only applicable for base + zpa or zpa_enabled = true deployment types where DNS Forward Zones are being created. 
##     Two example domains are populated to show the mapping structure and syntax. GCP does require a trailing dot "." 
##     on all domain entries. ZPA Module will read through each to create a private managed zone per 
##     domain_names entry. Ucomment domain_names variable and add any additional appsegXX mappings as needed.

#domain_names = {
#  appseg1 = "app1.com."
#  appseg2 = "app2.com."
#}


#####################################################################################################################
##### Custom BYO variables. Only applicable for deployments without "base" resource requirements  #####
#####                                 E.g. "cc_asg"                                               #####
#####################################################################################################################
## 27. By default, this script will create two new GCP VPC Networks (CC Management and CC Service).
##     Uncomment if you want to deploy all resources to VPCs that already exists (true or false. Default: false)

#byo_vpc                                    = true

## 28. Provide your existing VPC Network friendly names. Only uncomment and modify if you set byo_vpc to true. (Default: null)

##byo_mgmt_vpc_name                         = "cc-mgmt-vpc-123"
##byo_service_vpc_name                      = "cc-service-vpc-123"

## 29. By default, this script will create a new subnet in both the mgmt and service VPC networks.
##     Uncomment if you want to deploy all resources to subnets that already exist (true or false. Default: false)
##     Dependencies require in order to reference existing subnets, the corresponding VPC must also already exist.
##     Setting byo_subnet to true means byo_vpc must ALSO be set to true.

#byo_subnets                                = true

## 30. Provide your existing Cloud Connector subnet friendly names. Only uncomment and modify if you set byo_subnets to true.
##
## Note: If setting byo_subnets, BOTH the mgmt and service subnets must already exist.

#byo_mgmt_subnet_name                       = "mgmt-vpc-mgmt-subnet"
#byo_service_subnet_name                    = "service-vpc-service-subnet"

## 31. By default, this script will create new Cloud Routers in both the mgmt and service VPC networks.
##     Uncomment if you want to deploy to VPCs where Cloud Routers already exsit. (true or false. Default: false)
##     Dependencies require in order to reference existing Cloud Routers, the corresponding VPC must also already exist.
##     Setting byo_router to true means byo_vpc must ALSO be set to true.

#byo_router                                 = true

## 32. Provider your existing Cloud Router friendly names. Only uncomment and modify if you set byo_router to true.
##
## Note: If setting byo_router, BOTH the mgmt and service VPC Cloud Routers must already exist.

#byo_mgmt_router_name                       = "mgmt-vpc-router"
#byo_service_router_name                    = "service-vpc-router"

## 33. By default, this script will create new Cloud NAT Gateways associated with VPC Cloud Routers in
##     both the mgmt and service VPC Networks. Uncomment if you want to deploy to VPCs where NAT Gateways
##     already exist. (true or false. Default: false).
##     Dependencies require in order to reference existing Cloud NAT Gateway, the corresponding VPC Networks
##     AND Cloud Routers must also already exist.
##     Setting byo_natgw to true means byo_vpc AND byo_router must ALSO be set to true.

#byo_natgw                                  = true

## 34. Provide your existing Cloud NAT Gateway friendly names. Only uncomment and modify if you set byo_natgw to true.

#byo_mgmt_natgw_name                        = "mgmt-vpc-natgw"
#byo_service_natgw_name                     = "service-vpc-natgw"


#####################################################################################################################
##### Override resource auto-name generation. Only change/set if required for your environment                  #####
##### ZSEC bash script will NOT prompt for setting any of these values, thus most values default                #####
##### to null/blank. Terraform logic uses this to auto-generate based on name_prefix-<name>-resource_tag        #####       
#####################################################################################################################

## Custom Service Account module name variables. These are ignored if byo_ccvm_service_account is set

#service_account_id = "example-sa-name"
#service_account_display_name = "example-sa-display-name"

## Custom Cloud Run Function module name variables. These are ignored if byo_function_service_account is set

#cloud_function_service_account_id = "example-sa-name"
#cloud_function_service_account_display_name = "example-sa-display-name"

## Custom CC VM/Instance Group module name variables

#instance_template_name_prefix = "template-name-prefix"

#### GCP Terraform provider recommends to use template name_prefix rather than name argument per:             ####
#### https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template ####
#### Setting any value for instance_template_name will set name_prefix to empty/null                          ####
#instance_template_name        = "template-name"

#instance_group_name = ["az-1-grp-name","az-2-grp-name"]
#base_instance_name = ["grp-1-base-name","grp-2-base-name"]

## Custom ILB module name variables

#ilb_backend_service_name = "backend-service-name"
#ilb_health_check_name = "health-check-name"
#ilb_frontend_ip_name = "frontend-ip-name"
#ilb_forwarding_rule_name = "forwarding-rule-name"
#fw_ilb_health_check_name = "fw-health-check-name"

## Custom Network/firewall module name variables

#fw_cc_mgmt_ssh_ingress_name = "fw-rule-ssh-ingress-to-cc-mgmt"
#fw_cc_service_default_name = "fw-rule-default-all-ingress-to-cc-service"
#fw_cc_mgmt_zssupport_tunnel_name = "fw-rule-cc-mgmt-zssupport-tunnel"
