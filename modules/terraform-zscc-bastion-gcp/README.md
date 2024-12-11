# Zscaler Cloud Connector / GCP Compute Instance (Bastion Host) Module

This module creates a new Ubuntu Linux compute instance needed to deploy a publicly accessible bastion/jump host for Cloud Connector and workload access in test Greenfield/POV environments.

By default, the example Terraform template will create a new dedicated subnet in the same Management VPC Network as the Cloud Connector(s). The instance will be assigned a dynamic/ephemeral public IP address with security controls permitting SSH (TCP/22) inbound access from the internet unless specified otherwise. This module is NOT required for production deployments and, if deployed, should have inbound access locked down ideally.

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
| [google_compute_firewall.ssh_internet_ingress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_instance.bastion](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_service_account.service_account_bastion](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bastion_ssh_allow_ip"></a> [bastion\_ssh\_allow\_ip](#input\_bastion\_ssh\_allow\_ip) | CIDR blocks of trusted networks for bastion host ssh access from Internet | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The bastion host instance type | `string` | `"e2-micro"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A prefix to associate to all the bastion module resources | `string` | `null` | no |
| <a name="input_public_subnet"></a> [public\_subnet](#input\_public\_subnet) | The public subnet where the bastion host has to be attached | `string` | n/a | yes |
| <a name="input_resource_tag"></a> [resource\_tag](#input\_resource\_tag) | A tag to associate to all bastion module resources | `string` | `null` | no |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | A public key uploaded to the bastion instance | `string` | n/a | yes |
| <a name="input_vpc_network"></a> [vpc\_network](#input\_vpc\_network) | Bastion VPC network | `string` | n/a | yes |
| <a name="input_workload_image_name"></a> [workload\_image\_name](#input\_workload\_image\_name) | Custom image name to be used for deploying bastion/workload appliances | `string` | `"ubuntu-os-cloud/ubuntu-2204-lts"` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | The zone that the machine should be created in. If it is not provided, the provider zone is used | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | Instance Public IP |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
