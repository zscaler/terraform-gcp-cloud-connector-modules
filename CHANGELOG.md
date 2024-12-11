## 0.2.0 (UNRELEASED)
FEATURES:
* Official support for HashiCorp Vault for secrets storage as an alternative to GCP Secret Manager
    - add: variables hcp_vault_enabled, hcp_vault_address, hcp_vault_secret_path, hcp_vault_role_name, hcp_vault_port, and hcp_vault_ips
    - **Dependency:** Requires new GCP Compute version (TBD)

ENHANCEMENTS:
* Module changes:
    - terraform-zscc-network-gcp
        - add pre-defined firewall rule for egress tcp/8200 to HashiCorp Vault (if that secrets storage option is selected)
    - terraform-zscc-iam-service-account-gcp
        - add google_service_account_iam_member.iam_token_creator resource for SA role dependency if HCP Vault with GCP Auth Method is utilized
        - add variable byo_ccvm_service_account for flexibility in providing and reference an existing Service Account ID rather than Terraform creating a new one
    - terraform-zscc-ilb-gcp
        - add explicit backend balancing_mode to "CONNECTION" as required for Passthrough Network ILB since a default empty/null value changed to UTILIZATION which is not supported
* add: zsec prompts for HashiCorp Vault selection and byo service account
* refactor: gcp provider bump to 6.13.0


## v0.1.2 (January 20, 2024)
ENHANCEMENTS:
* terraform-zscc-iam-service-account-gcp module customization support
    - add: variables service_account_id and service_account_display_name to more easily define CC Service Account Name creation
* terraform-zscc-ccvm-gcp module customization support
    - add: variables instance_template_name_prefix, base_instance_name, and instance_group_name
* terraform-zscc-ilb-gcp customization support
    - add: variables ilb_backend_service_name, ilb_health_check_name, ilb_frontend_ip_name, ilb_forwarding_rule_name, and fw_ilb_health_check_name
* terraform-zscc-network-gcp customization support
    - add: variables fw_cc_mgmt_ssh_ingress_name and fw_cc_service_default_name
    - add: variables fw_cc_mgmt_zssupport_tunnel_name and support_access_enabled
* refactor: gcp provider bump to 5.11.0

BUG FIXES:
* fix: google_secret_manager_secret_iam_member resource project id lookup to prevent unnecessary force replacement
* add: variable workload_count to greenfield templates to create multiple workloads across availability zones
* change: MIG from Managed to Stateful with persistent disk and nics


## v0.1.1 (November 14, 2023)
BUG FIXES:
* add support for VPC/Network resources in a separate Host Project than the Cloud Connector Service Project
* add variable project_host

ENHANCEMENTS:
* ZSEC bash script support for multiple projects (Host and Service) assuming Terraform Service Account has permissions to both
* Templates refactored to support GCP Marketplace image release


## v0.1.0 (October 16, 2023)
* Limited Availability Release. Image and access can be enabled to customers by reaching to Zscaler Support
