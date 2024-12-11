# Zscaler Cloud Connector / GCP Compute Instance (Workload Host) Module

This module creates a new Ubuntu Linux compute instance needed to deploy a private test workload machine for Cloud Connector Greenfield/POV environments.<br>
By default, the example Terraform template will create a new dedicated subnet in the same Service VPC Network as the Cloud Connector(s) with tagged default route with next-hop pointing to either a specific CC instance or ILB.<br>

This module is NOT required for production deployments.

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
| [google_compute_firewall.ssh_intranet_workload](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_instance.server_host](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_service_account.service_account_workload](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_ssh_from_internal_cidr"></a> [allowed\_ssh\_from\_internal\_cidr](#input\_allowed\_ssh\_from\_internal\_cidr) | CIDR allowed to ssh the bastion host from Intranet | `list(string)` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The bastion host instance type | `string` | `"e2-micro"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A prefix to associate to all the workload module resources | `string` | `null` | no |
| <a name="input_resource_tag"></a> [resource\_tag](#input\_resource\_tag) | A tag to associate to all workload module resources | `string` | `null` | no |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | A public key uploaded to the bastion instance | `string` | n/a | yes |
| <a name="input_subnet"></a> [subnet](#input\_subnet) | A subnet the workload host is in | `string` | n/a | yes |
| <a name="input_vpc_network"></a> [vpc\_network](#input\_vpc\_network) | Workload VPC network | `string` | n/a | yes |
| <a name="input_workload_count"></a> [workload\_count](#input\_workload\_count) | The number of Workload VMs to deploy | `number` | `1` | no |
| <a name="input_workload_image_name"></a> [workload\_image\_name](#input\_workload\_image\_name) | Custom image name to be used for deploying bastion/workload appliances | `string` | `"ubuntu-os-cloud/ubuntu-2204-lts"` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | The zone that the machine should be created in. If it is not provided, the provider zone is used | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | Instance Private IP |
| <a name="output_workload_network_tag"></a> [workload\_network\_tag](#output\_workload\_network\_tag) | Network tag as the source of a route rule |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
