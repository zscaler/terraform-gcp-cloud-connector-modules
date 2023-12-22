## UNRELEASED (TBD)
ENHANCEMENTS:
* terraform-zscc-iam-service-account-gcp module customization support
    - add: variables service_account_id and service_account_display_name to more easily define CC Service Account Name creation
* terraform-zscc-ccvm-gcp module customization support
    - add: variables instance_template_name_prefix, base_instance_name, and instance_group_name
* terraform-zscc-ilb-gcp customization support
    - add: variables ilb_backend_service_name, ilb_health_check_name, ilb_frontend_ip_name, ilb_forwarding_rule_name, and fw_ilb_health_check_name
* terraform-zscc-network-gcp customization support
    - add: variables fw_cc_mgmt_ssh_ingress_name and fw_cc_service_default_name

BUG FIXES:
* fix: google_secret_manager_secret_iam_member resource project id lookup to prevent unnecessary force replacement

## v0.1.1 (November 14, 2023)
BUG FIXES:
* add support for VPC/Network resources in a separate Host Project than the Cloud Connector Service Project
* add variable project_host

ENHANCEMENTS:
* ZSEC bash script support for multiple projects (Host and Service) assuming Terraform Service Account has permissions to both
* Templates refactored to support GCP Marketplace image release


## v0.1.0 (October 16, 2023)
* Limited Availability Release. Image and access can be enabled to customers by reaching to Zscaler Support
