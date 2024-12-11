# Zscaler Cloud Connector / GCP Cloud Loadbalancer (Cloud Connector) Module

This module creates all GCP Load Balancer needed to deploy Cloud Connector appliances resliently in Google Cloud including: a regional backend service; frontend IP forwarding rule for all ports and protocols; HTTP health probe checks and necessary firewall rules to permit Cloud Connector to receive the health checks.


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.7, < 2.0.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 6.13.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | ~> 6.13.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_address.ilb_ip_address](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_firewall.allow_cc_health_check](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_forwarding_rule.ilb_forwarding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |
| [google_compute_health_check.cc_health_check](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_health_check) | resource |
| [google_compute_region_backend_service.backend_service](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_backend_service) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_global_access"></a> [allow\_global\_access](#input\_allow\_global\_access) | true: Clients can access ILB from all regions; false: Only allow access from clients in the same region as the internal load balancer. | `bool` | `false` | no |
| <a name="input_fw_ilb_health_check_name"></a> [fw\_ilb\_health\_check\_name](#input\_fw\_ilb\_health\_check\_name) | Name of the firewall rule created with ILB permitting GCP health check probe source ranges on the configured HTTP probe port inbound to the Cloud Connector service interface(s) | `string` | n/a | yes |
| <a name="input_health_check_interval"></a> [health\_check\_interval](#input\_health\_check\_interval) | Interval for ILB health check probing, in seconds, of Cloud Connector targets | `number` | `10` | no |
| <a name="input_healthy_threshold"></a> [healthy\_threshold](#input\_healthy\_threshold) | The number of successful health checks required before an unhealthy target becomes healthy. Minimum 2 and maximum 10 | `number` | `2` | no |
| <a name="input_http_probe_port"></a> [http\_probe\_port](#input\_http\_probe\_port) | Port number for Cloud Connector cloud init to enable listener port for HTTP probe from GCP LB | `number` | `50000` | no |
| <a name="input_ilb_backend_service_name"></a> [ilb\_backend\_service\_name](#input\_ilb\_backend\_service\_name) | Name of the resource. Provided by the client when the resource is created. The name must be 1-63 characters long, and comply with RFC1035. Specifically, the name must be 1-63 characters long and match the regular expression [a-z]([-a-z0-9]*[a-z0-9])? which means the first character must be a lowercase letter, and all following characters must be a dash, lowercase letter, or digit, except the last character, which cannot be a dash | `string` | n/a | yes |
| <a name="input_ilb_forwarding_rule_name"></a> [ilb\_forwarding\_rule\_name](#input\_ilb\_forwarding\_rule\_name) | Name of the resource; provided by the client when the resource is created. The name must be 1-63 characters long, and comply with RFC1035. Specifically, the name must be 1-63 characters long and match the regular expression [a-z]([-a-z0-9]*[a-z0-9])? which means the first character must be a lowercase letter, and all following characters must be a dash, lowercase letter, or digit, except the last character, which cannot be a dash | `string` | n/a | yes |
| <a name="input_ilb_frontend_ip_name"></a> [ilb\_frontend\_ip\_name](#input\_ilb\_frontend\_ip\_name) | Name of the resource. The name must be 1-63 characters long, and comply with RFC1035. Specifically, the name must be 1-63 characters long and match the regular expression [a-z]([-a-z0-9]*[a-z0-9])? which means the first character must be a lowercase letter, and all following characters must be a dash, lowercase letter, or digit, except the last character, which cannot be a dash | `string` | n/a | yes |
| <a name="input_ilb_health_check_name"></a> [ilb\_health\_check\_name](#input\_ilb\_health\_check\_name) | Name of the resource. Provided by the client when the resource is created. The name must be 1-63 characters long, and comply with RFC1035. Specifically, the name must be 1-63 characters long and match the regular expression [a-z]([-a-z0-9]*[a-z0-9])? which means the first character must be a lowercase letter, and all following characters must be a dash, lowercase letter, or digit, except the last character, which cannot be a dash | `string` | n/a | yes |
| <a name="input_instance_groups"></a> [instance\_groups](#input\_instance\_groups) | GCP instance group | `list(string)` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Google Cloud Project name. This is required and implied 'service project' with respect to GCP Shared VPC architecture | `string` | n/a | yes |
| <a name="input_project_host"></a> [project\_host](#input\_project\_host) | Google Cloud Host Project name. Defaults to null. This variable is intended for environments where different resources might exist in separate host and service projects | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Google Cloud region | `string` | n/a | yes |
| <a name="input_session_affinity"></a> [session\_affinity](#input\_session\_affinity) | Controls the distribution of new connections from clients to the load balancer's backend VMs | `string` | `"CLIENT_IP_PROTO"` | no |
| <a name="input_unhealthy_threshold"></a> [unhealthy\_threshold](#input\_unhealthy\_threshold) | The number of unsuccessful health checks required before an healthy target becomes unhealthy. Minimum 2 and maximum 10 | `number` | `3` | no |
| <a name="input_vpc_network"></a> [vpc\_network](#input\_vpc\_network) | Cloud Connector Service VPC network | `string` | n/a | yes |
| <a name="input_vpc_subnetwork_ccvm_service"></a> [vpc\_subnetwork\_ccvm\_service](#input\_vpc\_subnetwork\_ccvm\_service) | A subnetwork for ILB | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ilb_ip_address"></a> [ilb\_ip\_address](#output\_ilb\_ip\_address) | IP address designated for ILB |
| <a name="output_ilb_ip_address_link"></a> [ilb\_ip\_address\_link](#output\_ilb\_ip\_address\_link) | ID for ILB designated compute address |
| <a name="output_next_hop_ilb"></a> [next\_hop\_ilb](#output\_next\_hop\_ilb) | ID for ILB IP |
| <a name="output_next_hop_ilb_ip_address"></a> [next\_hop\_ilb\_ip\_address](#output\_next\_hop\_ilb\_ip\_address) | ILB front end IP address |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
