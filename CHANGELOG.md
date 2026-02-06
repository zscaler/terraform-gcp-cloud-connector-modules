## 0.3.0 (January 23, 2026)
FEATURES:
* Official support for Cloud Connector Auto Scaling on GCP - (Requires new Marketplace Compute Image: zs-cc-ga-02042026 or greater )
    - add: module terraform-zscc-cloud-function-gcp for Cloud Run Function and dependency resources
    - update: module terraform-zscc-ccvm-gcp for autoscaling_enabled conditions including: dynamically removing stateful disk and internal_ip attributes and the addition of google_compute_autoscaler.cc_asg resource
    - update: module terraform-zscc-iam-service-account-gcp to include Monitoring Metric Writer role for CC SA when autoscaling is enabled
    - add: zsec script support for ASG greenfield and brownfield deployments

ENHANCEMENTS:
* add: variable marketplace_image for all deployment templates defaulting to the latest available image "zs-cc-ga-02042026" upgraded to ZscalerOS 42 and supporting autoscaling
* add: ssh_config creations to deployment templates outputs.tf for improvement UX
* add: variable tags applied to google_compute_instance_template.cc_instance_template resource

## 0.2.1 (February 25, 2025)
BUG FIXES:
* fix: add missing lb_vip attribute back to ilb based template userdata file generation

## 0.2.0 (February 13, 2025)
FEATURES:
* Official support for HashiCorp Vault for secrets storage as an alternative to GCP Secret Manager
    - add: variables hcp_vault_enabled, hcp_vault_address, hcp_vault_secret_path, hcp_vault_role_name, hcp_vault_port, and hcp_vault_ips
    - **Dependency:** Requires deploying new Cloud Connectors with marketplace image zs-cc-ga-02022025

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
