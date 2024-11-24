# Zscaler "cc_ilb" deployment type

This deployment type is intended for production/brownfield purposes. Full set of resources provisioned listed below, but by default this will effectively create all network infrastructure dependencies for a GCP environment. Creates 1 new "Management" VPC with 1 CC-Mgmt subnet; 1 "Service" VPC with 1 CC-Service subnet; 1 Cloud Router + NAT Gateway per VPC; generates local key pair .pem file for ssh access to all VMs. All network infrastructure resource have conditional "byo" variables, that can be inputted if they already exist (like VPC, subnet, Cloud Router, and Cloud NAT).<br>

Additionally: Creates 1 Cloud Connector compute instance template + between [1-3] zonal managed instance groups to deploy Cloud Connector appliances with a dedicated service account associated for accessing Secret Manager. This template also leverages the terraform-zscc-ilb-gcp module to create the necessary backend service, forwarding rule, health check, and firewall rules needed to front all cloud connector instances for highly available/resilient workload traffic forwarding; and optionally the terraform-zscc-cloud-dns-gcp module to create Google Cloud DNS forward zones intended for ZPA App Segment DNS redirection.

![cc_ilb](https://github.com/zscaler/terraform-gcp-cloud-connector-modules/blob/topologies/docs/assets/example_topologies/cc_ilb.svg)

## How to deploy:

### Option 1 (guided):
Optional - First edit examples/cc_ilb/terraform.tfvars with any "byo" variable values that already exist in your environment and save the file.
From the examples directory, run the zsec bash script that walks to all required inputs.
- ./zsec up
- enter "brownfield"
- enter "cc_ilb"
- follow the remainder of the authentication and configuration input prompts.
- script will detect client operating system and download/run a specific version of terraform in a temporary bin directory
- inputs will be validated and terraform init/apply will automatically exectute.
- verify all resources that will be created/modified and enter "yes" to confirm

### Option 2 (manual):
Modify/populate any required variable input values in examples/cc_ilb/terraform.tfvars file and save.

From cc_ilb directory execute:
- terraform init
- terraform apply

## How to destroy:

### Option 1 (guided):
From the examples directory, run the zsec bash script that walks to all required inputs.
- ./zsec destroy

### Option 2 (manual):
From cc_ilb directory execute:
- terraform destroy

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.7, < 2.0.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 5.11.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.2.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.1.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.3.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 3.4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | ~> 5.11.0 |
| <a name="provider_local"></a> [local](#provider\_local) | ~> 2.2.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.3.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | ~> 3.4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cc_vm"></a> [cc\_vm](#module\_cc\_vm) | ../../modules/terraform-zscc-ccvm-gcp | n/a |
| <a name="module_cloud_dns"></a> [cloud\_dns](#module\_cloud\_dns) | ../../modules/terraform-zscc-cloud-dns-gcp | n/a |
| <a name="module_iam_service_account"></a> [iam\_service\_account](#module\_iam\_service\_account) | ../../modules/terraform-zscc-iam-service-account-gcp | n/a |
| <a name="module_ilb"></a> [ilb](#module\_ilb) | ../../modules/terraform-zscc-ilb-gcp | n/a |
| <a name="module_network"></a> [network](#module\_network) | ../../modules/terraform-zscc-network-gcp | n/a |

## Resources

| Name | Type |
|------|------|
| [local_file.private_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.testbed](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.user_data_file](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [tls_private_key.key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [google_compute_image.zs_cc_img](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image) | data source |
| [google_compute_zones.available](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_global_access"></a> [allow\_global\_access](#input\_allow\_global\_access) | true: Clients can access ILB from all regions; false: Only allow access from clients in the same region as the internal load balancer. | `bool` | `false` | no |
| <a name="input_allowed_ports"></a> [allowed\_ports](#input\_allowed\_ports) | A list of ports to permit inbound to Cloud Connector Service VPC. Default empty list means to allow all. | `list(string)` | `[]` | no |
| <a name="input_az_count"></a> [az\_count](#input\_az\_count) | Default number zonal instance groups to create based on availability zone | `number` | `2` | no |
| <a name="input_base_instance_name"></a> [base\_instance\_name](#input\_base\_instance\_name) | The base instance name to use for instances in this group. The value must be a valid RFC1035 name. Supported characters are lowercase letters, numbers, and hyphens (-). Instances are named by appending a hyphen and a random four-character string to the base instance name | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_byo_ccvm_service_account"></a> [byo\_ccvm\_service\_account](#input\_byo\_ccvm\_service\_account) | "Customer provided existing Service Account ID. If set, module will use this instead of trying to create a new one<br> - The name of the service account within the project (e.g. my-service)<br> - The fully-qualified path to a service account resource (e.g. projects/my-project/serviceAccounts/...)<br> - The email address of the service account (e.g. my-service@my-project.iam.gserviceaccount.com)" | `string` | `""` | no |
| <a name="input_byo_mgmt_natgw_name"></a> [byo\_mgmt\_natgw\_name](#input\_byo\_mgmt\_natgw\_name) | User provided existing GCP NAT Gateway friendly name for Management VPC | `string` | `null` | no |
| <a name="input_byo_mgmt_router_name"></a> [byo\_mgmt\_router\_name](#input\_byo\_mgmt\_router\_name) | User provided existing GCP Compute Router friendly name for Management VPC | `string` | `null` | no |
| <a name="input_byo_mgmt_subnet_name"></a> [byo\_mgmt\_subnet\_name](#input\_byo\_mgmt\_subnet\_name) | User provided existing GCP Subnet friendly name for Management VPC | `string` | `null` | no |
| <a name="input_byo_mgmt_vpc_name"></a> [byo\_mgmt\_vpc\_name](#input\_byo\_mgmt\_vpc\_name) | User provided existing GCP VPC friendly name for Management interface | `string` | `null` | no |
| <a name="input_byo_natgw"></a> [byo\_natgw](#input\_byo\_natgw) | Bring your own GCP NAT Gateway Cloud Connector | `bool` | `false` | no |
| <a name="input_byo_router"></a> [byo\_router](#input\_byo\_router) | Bring your own GCP Compute Router for Cloud Connector | `bool` | `false` | no |
| <a name="input_byo_service_natgw_name"></a> [byo\_service\_natgw\_name](#input\_byo\_service\_natgw\_name) | User provided existing GCP NAT Gateway friendly name for Forwarding/Service VPC | `string` | `null` | no |
| <a name="input_byo_service_router_name"></a> [byo\_service\_router\_name](#input\_byo\_service\_router\_name) | User provided existing GCP Compute Router friendly name for Forwarding/Service VPC | `string` | `null` | no |
| <a name="input_byo_service_subnet_name"></a> [byo\_service\_subnet\_name](#input\_byo\_service\_subnet\_name) | User provided existing GCP Subnet friendly name for Forwarding/Service VPC | `string` | `null` | no |
| <a name="input_byo_service_vpc_name"></a> [byo\_service\_vpc\_name](#input\_byo\_service\_vpc\_name) | User provided existing GCP VPC friendly name for Forwarding/Service interfaces | `string` | `null` | no |
| <a name="input_byo_subnets"></a> [byo\_subnets](#input\_byo\_subnets) | Bring your own GCP Subnets for Cloud Connector | `bool` | `false` | no |
| <a name="input_byo_vpc"></a> [byo\_vpc](#input\_byo\_vpc) | Bring your own GCP VPC for Cloud Connector | `bool` | `false` | no |
| <a name="input_cc_count"></a> [cc\_count](#input\_cc\_count) | Default number of Cloud Connector appliances to create per Instance Group/Availability Zone | `number` | `2` | no |
| <a name="input_cc_vm_prov_url"></a> [cc\_vm\_prov\_url](#input\_cc\_vm\_prov\_url) | Zscaler Cloud Connector Provisioning URL | `string` | n/a | yes |
| <a name="input_ccvm_instance_type"></a> [ccvm\_instance\_type](#input\_ccvm\_instance\_type) | Cloud Connector Instance Type | `string` | `"n2-standard-2"` | no |
| <a name="input_credentials"></a> [credentials](#input\_credentials) | Path to the service account json file for terraform to authenticate to Google Cloud | `string` | n/a | yes |
| <a name="input_default_nsg"></a> [default\_nsg](#input\_default\_nsg) | Default CIDR list to permit workload traffic destined for Cloud Connector | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_domain_names"></a> [domain\_names](#input\_domain\_names) | Domain names fqdn/wildcard to have Google Cloud DNS zone forward ZPA App Segment DNS requests to Cloud Connector | `map(any)` | `{}` | no |
| <a name="input_fw_cc_mgmt_hcp_vault_address_name"></a> [fw\_cc\_mgmt\_hcp\_vault\_address\_name](#input\_fw\_cc\_mgmt\_hcp\_vault\_address\_name) | The name of the compute firewall created on the user defined Cloud Connector Management VPC Network permitting CC to access to HCP Vault Address port number | `string` | `null` | no |
| <a name="input_fw_cc_mgmt_ssh_ingress_name"></a> [fw\_cc\_mgmt\_ssh\_ingress\_name](#input\_fw\_cc\_mgmt\_ssh\_ingress\_name) | The name of the compute firewall created on the user defined Cloud Connector Management VPC Network permitting SSH inbound from the VPC CIDR range by default | `string` | `null` | no |
| <a name="input_fw_cc_mgmt_zssupport_tunnel_name"></a> [fw\_cc\_mgmt\_zssupport\_tunnel\_name](#input\_fw\_cc\_mgmt\_zssupport\_tunnel\_name) | The name of the compute firewall created on the user defined Cloud Connector Management VPC Network permitting CC to establish zssupport tunnel | `string` | `null` | no |
| <a name="input_fw_cc_service_default_name"></a> [fw\_cc\_service\_default\_name](#input\_fw\_cc\_service\_default\_name) | The name of the compute firewall created on the user defined Cloud Connector Service VPC Network permitting workload traffic to be sent to Zscaler | `string` | `null` | no |
| <a name="input_fw_ilb_health_check_name"></a> [fw\_ilb\_health\_check\_name](#input\_fw\_ilb\_health\_check\_name) | Name of the firewall rule created with ILB permitting GCP health check probe source ranges on the configured HTTP probe port inbound to the Cloud Connector service interface(s) | `string` | `null` | no |
| <a name="input_hcp_gcp_auth_role_type"></a> [hcp\_gcp\_auth\_role\_type](#input\_hcp\_gcp\_auth\_role\_type) | Customer managed HashiCorp Vault GCP Auth Method | `string` | `"gcp_iam"` | no |
| <a name="input_hcp_vault_address"></a> [hcp\_vault\_address](#input\_hcp\_vault\_address) | Customer managed HashiCorp Vault URL; including leading https (if applicable) and trailing port number | `string` | `""` | no |
| <a name="input_hcp_vault_enabled"></a> [hcp\_vault\_enabled](#input\_hcp\_vault\_enabled) | True/False used to determine specific HCP Vault configured network firewall and Service Account IAM roles. Default is false | `bool` | `false` | no |
| <a name="input_hcp_vault_ips"></a> [hcp\_vault\_ips](#input\_hcp\_vault\_ips) | Default CIDR list to permit Cloud Connector traffic destined for customer defined HCP Vault address(es) | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_hcp_vault_port"></a> [hcp\_vault\_port](#input\_hcp\_vault\_port) | Default TCP Port Number for customer defined HCP Vault address(es) | `string` | `"8200"` | no |
| <a name="input_hcp_vault_role_name"></a> [hcp\_vault\_role\_name](#input\_hcp\_vault\_role\_name) | Customer managed HashiCorp Role Name | `string` | `""` | no |
| <a name="input_hcp_vault_secret_path"></a> [hcp\_vault\_secret\_path](#input\_hcp\_vault\_secret\_path) | Customer managed HashiCorp Vault secret path. The path to a secret is formed from three parts: <namespace>/<engine mount point>/<path to secret>. If you are not using the enterprise version of Vault, you should omit the first part | `string` | `""` | no |
| <a name="input_health_check_interval"></a> [health\_check\_interval](#input\_health\_check\_interval) | Interval for ILB health check probing, in seconds, of Cloud Connector targets | `number` | `10` | no |
| <a name="input_healthy_threshold"></a> [healthy\_threshold](#input\_healthy\_threshold) | The number of successful health checks required before an unhealthy target becomes healthy. Minimum 2 and maximum 10 | `number` | `2` | no |
| <a name="input_http_probe_port"></a> [http\_probe\_port](#input\_http\_probe\_port) | Port number for Cloud Connector cloud init to enable listener port for HTTP probe from GCP LB | `number` | `50000` | no |
| <a name="input_ilb_backend_service_name"></a> [ilb\_backend\_service\_name](#input\_ilb\_backend\_service\_name) | Name of the resource. Provided by the client when the resource is created. The name must be 1-63 characters long, and comply with RFC1035. Specifically, the name must be 1-63 characters long and match the regular expression [a-z]([-a-z0-9]*[a-z0-9])? which means the first character must be a lowercase letter, and all following characters must be a dash, lowercase letter, or digit, except the last character, which cannot be a dash | `string` | `null` | no |
| <a name="input_ilb_forwarding_rule_name"></a> [ilb\_forwarding\_rule\_name](#input\_ilb\_forwarding\_rule\_name) | Name of the resource; provided by the client when the resource is created. The name must be 1-63 characters long, and comply with RFC1035. Specifically, the name must be 1-63 characters long and match the regular expression [a-z]([-a-z0-9]*[a-z0-9])? which means the first character must be a lowercase letter, and all following characters must be a dash, lowercase letter, or digit, except the last character, which cannot be a dash | `string` | `null` | no |
| <a name="input_ilb_frontend_ip_name"></a> [ilb\_frontend\_ip\_name](#input\_ilb\_frontend\_ip\_name) | Name of the resource. The name must be 1-63 characters long, and comply with RFC1035. Specifically, the name must be 1-63 characters long and match the regular expression [a-z]([-a-z0-9]*[a-z0-9])? which means the first character must be a lowercase letter, and all following characters must be a dash, lowercase letter, or digit, except the last character, which cannot be a dash | `string` | `null` | no |
| <a name="input_ilb_health_check_name"></a> [ilb\_health\_check\_name](#input\_ilb\_health\_check\_name) | Name of the resource. Provided by the client when the resource is created. The name must be 1-63 characters long, and comply with RFC1035. Specifically, the name must be 1-63 characters long and match the regular expression [a-z]([-a-z0-9]*[a-z0-9])? which means the first character must be a lowercase letter, and all following characters must be a dash, lowercase letter, or digit, except the last character, which cannot be a dash | `string` | `null` | no |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | Custom image name to be used for deploying Cloud Connector appliances. Ideally all VMs should be on the same Image as templates always pull the latest from Google Marketplace. This variable is provided if a customer desires to override/retain an old ami for existing deployments rather than upgrading and forcing a replacement. It is also inputted as a list to facilitate if a customer desired to manually upgrade select CCs deployed based on the cc\_count index | `string` | `""` | no |
| <a name="input_instance_group_name"></a> [instance\_group\_name](#input\_instance\_group\_name) | The name of the Instance Group Manager. Must be 1-63 characters long and comply with RFC1035. Supported characters include lowercase letters, numbers, and hyphens | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_instance_template_name"></a> [instance\_template\_name](#input\_instance\_template\_name) | The name of the instance template. Conflicts with variable instance\_template\_name\_prefix | `string` | `""` | no |
| <a name="input_instance_template_name_prefix"></a> [instance\_template\_name\_prefix](#input\_instance\_template\_name\_prefix) | Creates a unique Instance Template name beginning with the specified prefix. Conflicts with variable instance\_template\_name | `string` | `""` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | The name prefix for all your resources | `string` | `"zscc"` | no |
| <a name="input_project"></a> [project](#input\_project) | Google Cloud project name | `string` | n/a | yes |
| <a name="input_project_host"></a> [project\_host](#input\_project\_host) | Google Cloud Host Project name. Defaults to null. This variable is intended for environments where different resources might exist in separate host and service projects | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Google Cloud region | `string` | n/a | yes |
| <a name="input_secret_name"></a> [secret\_name](#input\_secret\_name) | GCP Secret Manager friendly name. Not required if using HashiCorp Vault | `string` | `""` | no |
| <a name="input_service_account_display_name"></a> [service\_account\_display\_name](#input\_service\_account\_display\_name) | Custom Service Account display name string for Cloud Connector | `string` | `null` | no |
| <a name="input_service_account_id"></a> [service\_account\_id](#input\_service\_account\_id) | Custom Service Account ID string for Cloud Connector | `string` | `null` | no |
| <a name="input_session_affinity"></a> [session\_affinity](#input\_session\_affinity) | Controls the distribution of new connections from clients to the load balancer's backend VMs | `string` | `"CLIENT_IP_PROTO"` | no |
| <a name="input_subnet_cc_mgmt"></a> [subnet\_cc\_mgmt](#input\_subnet\_cc\_mgmt) | A subnet IP CIDR for the Cloud Connector in the Management VPC | `string` | `"10.0.1.0/24"` | no |
| <a name="input_subnet_cc_service"></a> [subnet\_cc\_service](#input\_subnet\_cc\_service) | A subnet IP CIDR for the Cloud Connector/Load Balancer in the Service VPC | `string` | `"10.1.1.0/24"` | no |
| <a name="input_support_access_enabled"></a> [support\_access\_enabled](#input\_support\_access\_enabled) | Enable a specific outbound firewall rule for Cloud Connector to be able to establish connectivity for Zscaler support access. Default is true | `bool` | `true` | no |
| <a name="input_tls_key_algorithm"></a> [tls\_key\_algorithm](#input\_tls\_key\_algorithm) | algorithm for tls\_private\_key resource | `string` | `"RSA"` | no |
| <a name="input_unhealthy_threshold"></a> [unhealthy\_threshold](#input\_unhealthy\_threshold) | The number of unsuccessful health checks required before an healthy target becomes unhealthy. Minimum 2 and maximum 10 | `number` | `3` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | (Optional) Availability zone names. Only required if automatic zones selection based on az\_count is undesirable | `list(string)` | `[]` | no |
| <a name="input_zpa_enabled"></a> [zpa\_enabled](#input\_zpa\_enabled) | Configure Cloud DNS for ZPA zone forwarding | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_testbedconfig"></a> [testbedconfig](#output\_testbedconfig) | Google Cloud Testbed results |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
