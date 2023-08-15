## This is only a sample terraform.tfvars file.
## Uncomment and change the below variables according to your specific environment

## Variables 1-12 are populated automically if terraform is ran via ZSEC bash script.
## Modifying the variables in this file will override any inputs from ZSEC.


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

## 5. GCP Secrets Manager Secret ID/Resoure Name from Secrets Manager E.g projects/1234567890123/secrets/secret_name

#secret_name                                =  "projects/1234567890123/secrets/secret_name"

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
#ccvm_instance_type                         = "n2-standard-4"
#ccvm_instance_type                         = "e2-standard-4"
#ccvm_instance_type                         = "n2d-standard-4"
#ccvm_instance_type                         = "n2-standard-8"
#ccvm_instance_type                         = "e2-standard-8"
#ccvm_instance_type                         = "n2d-standard-8"

## 9. Network Configuration:
##    Subnet space. (Minimum /28 required. Uncomment and modify if byo_vpc is set to true but byo_subnets is left false meaning you want terraform to create 
##    NEW subnets in those existing VPCs.

## Note: These Greenfield templates that include a test workload and bastion host will create a total of two VPC Networks in the same Project ID. Putting
##       Host/Services and Applications in the same Project is generally not a GCP recommended best practice. For simplicity, we will create a "Management"
##       VPC consisting of the public bastion VM (subnet_bastion) and the Cloud Connector Mgmt NIC (subnet_cc_mgmt). We will also create a "Service" VPC
##       consisting of the workload VM (subnet_workload) and the Cloud Connector Service NIC (subnet_cc_service).

#subnet_bastion                             = "10.0.0.0/24"
#subnet_workload                            = "10.1.2.0/24"
#subnet_cc_mgmt                             = "10.0.1.0/24"
#subnet_cc_service                          = "10.1.1.0/24"

## 10. Availabilty Zone resiliency configuration:

## Option A. By default, Terraform will perform a lookup on the region being deployed for what/how many availability zones are currently available for use.
##           Based on this output, we will take the first X number of available zones per az_count and create Compute Instance Groups in in each. Available 
##           input range 1-3 (Default: 1) 

## Example: Region is us-central1 with az_count set to 2. Terraform will create 1 Instance Group in us-central1-a and 1x Instance Group in us-central1-b
##          (or whatever first two zones report back as available)

#az_count                                   = 2


## Option B. If you require Instance Groups to be set explicitly in certain availability zones, you can override the region lookup and set the zones.

## Note: By setting zone names here, Terraform will ignore any value set for variable az_count. We also cannot verify the availability correct naming syntax
##       of the names set.

#zones                                      = ["us-central1-a","us-central1-b"]

## 11. The number of Cloud Connector appliances to provision per Instance Group/Availability Zone.
##    (Default: varies per deployment type template)
##    E.g. cc_count set to 2 and var.az_count or var.zones set to 2 will create 2x Zonal Instance Groups with 2x target CCs in each Instance Group

#cc_count                                   = 2

## 12. Custom image name to used for deploying Cloud Connector appliances. By default, Terraform will lookup the latest image version from the Google Marketplace.
##     This variable is provided if a customer desires to override/retain a specific image name/Instance Template version

## Note: It is NOT RECOMMENDED to statically set CC image versions. Zscaler recommends always running/deploying the latest version template

#image_name                                 = "developer-image-gcp-freebsd11-202307212347"
