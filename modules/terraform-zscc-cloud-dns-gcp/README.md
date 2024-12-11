# Zscaler Cloud Connector / GCP Cloud DNS Module

This module creates the required resource dependencies to deploy Google Cloud DNS that can be utilized to facilitate conditional DNS forwarding from GCP to Zscaler Cloud Connector for ZPA resolution and/or ZIA DNS Controls security.

## Considerations
* If you are not currently leveraging Cloud DNS resources via API, you may need to enable prior to running Terraform. Instructions for enabling Cloud DNS API can be found [here](https://cloud.google.com/dns/docs/zones).
* Terraform may need additional permissions to create/delete DNS Zones (dns.managed*) such as the pre-defined DNS Administrator role.

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
| [google_compute_firewall.allow_cloud_dns](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_dns_managed_zone.dns_forward_zone](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain_names"></a> [domain\_names](#input\_domain\_names) | Domain names fqdn/wildcard to have Google Cloud DNS zone forward ZPA App Segment DNS requests to Cloud Connector | `map(any)` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A prefix to associate to all the bastion module resources | `string` | `null` | no |
| <a name="input_project"></a> [project](#input\_project) | Google Cloud Project name. This is required and implied 'service project' with respect to GCP Shared VPC architecture | `string` | n/a | yes |
| <a name="input_project_host"></a> [project\_host](#input\_project\_host) | Google Cloud Host Project name. Defaults to null. This variable is intended for environments where different resources might exist in separate host and service projects | `string` | `null` | no |
| <a name="input_resource_tag"></a> [resource\_tag](#input\_resource\_tag) | A random string for the resource name | `string` | n/a | yes |
| <a name="input_target_address"></a> [target\_address](#input\_target\_address) | Google Cloud DNS queries will be conditionally forwarded to these target IP addresses. Default is the Cloud Connector ILB frontend IP (or service IP for standalone) | `list(string)` | n/a | yes |
| <a name="input_vpc_networks"></a> [vpc\_networks](#input\_vpc\_networks) | VPC Networks to bind DNS Zone forwarding to | `list(string)` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
