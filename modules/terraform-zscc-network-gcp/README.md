# Zscaler Cloud Connector / GCP Network Infrastructure Module

This module has multi-purpose use and is leveraged by all other Zscaler Cloud Connector child modules in some capacity. All network infrastructure resources pertaining to connectivity dependencies for a successful Cloud Connector deployment in a private subnet are referenced here. Full list of resources can be found below, but in general this module will handle all VPC, Subnets, Cloud Routers, NAT Gateways, VPC peering and/or firewall dependencies to build out a resilient GCP network architecture. Most resources also have "conditional create" capabilities where, by default, they will all be created unless instructed not to with various "byo" variables. Use cases are documented in more detail in each description in variables.tf as well as the terraform.tfvars example file for all non-base deployment types (ie: cc_ilb, etc.).


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.7, < 2.0.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 4.70.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | ~> 4.70.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.default_service](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.ssh_intranet_cc_mgmt](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_network.mgmt_vpc_network](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_network.service_vpc_network](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_network_peering.management_to_service](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_peering) | resource |
| [google_compute_network_peering.service_to_management](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_peering) | resource |
| [google_compute_router.mgmt_vpc_router](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router) | resource |
| [google_compute_router.service_vpc_router](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router) | resource |
| [google_compute_router_nat.mgmt_vpc_nat_gateway](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat) | resource |
| [google_compute_router_nat.service_vpc_nat_gateway](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat) | resource |
| [google_compute_subnetwork.mgmt_subnet](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_compute_subnetwork.mgmt_vpc_subnet_bastion](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_compute_subnetwork.service_subnet](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_compute_subnetwork.vpc_subnet_workload](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_compute_network.mgmt_vpc_network_selected](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_network) | data source |
| [google_compute_network.service_vpc_network_selected](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_network) | data source |
| [google_compute_router.mgmt_vpc_router_selected](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_router) | data source |
| [google_compute_router.service_vpc_router_selected](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_router) | data source |
| [google_compute_router_nat.mgmt_vpc_nat_gateway_selected](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_router_nat) | data source |
| [google_compute_router_nat.service_vpc_nat_gateway_selected](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_router_nat) | data source |
| [google_compute_subnetwork.mgmt_subnet_selected](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_subnetwork) | data source |
| [google_compute_subnetwork.service_subnet_selected](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_subnetwork) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_ports"></a> [allowed\_ports](#input\_allowed\_ports) | A list of ports to permit inbound to Cloud Connector Service VPC. Default empty list means to allow all. | `list(string)` | `[]` | no |
| <a name="input_allowed_ssh_from_internal_cidr"></a> [allowed\_ssh\_from\_internal\_cidr](#input\_allowed\_ssh\_from\_internal\_cidr) | CIDR allowed to ssh the Cloud Connector from Intranet | `list(string)` | n/a | yes |
| <a name="input_bastion_enabled"></a> [bastion\_enabled](#input\_bastion\_enabled) | Configure bastion subnet in Management VPC for SSH access to Cloud Connector if set to true | `bool` | `false` | no |
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
| <a name="input_default_nsg"></a> [default\_nsg](#input\_default\_nsg) | Default CIDR list to permit workload traffic destined for Cloud Connector | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_fw_cc_mgmt_ssh_ingress_name"></a> [fw\_cc\_mgmt\_ssh\_ingress\_name](#input\_fw\_cc\_mgmt\_ssh\_ingress\_name) | The name of the compute firewall created on the user defined Cloud Connector Management VPC Network permitting SSH inbound from the VPC CIDR range by default | `string` | `null` | no |
| <a name="input_fw_cc_service_default_name"></a> [fw\_cc\_service\_default\_name](#input\_fw\_cc\_service\_default\_name) | The name of the compute firewall created on the user defined Cloud Connector Service VPC Network permitting workload traffic to be sent to Zscaler | `string` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A prefix to associate to all the module resources | `string` | `null` | no |
| <a name="input_project"></a> [project](#input\_project) | Google Cloud project name | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Google Cloud region | `string` | n/a | yes |
| <a name="input_resource_tag"></a> [resource\_tag](#input\_resource\_tag) | A random string for the resource name | `string` | n/a | yes |
| <a name="input_routing_mode"></a> [routing\_mode](#input\_routing\_mode) | The network-wide routing mode to use. If set to REGIONAL, this network's cloud routers will only advertise routes with subnetworks of this network in the same region as the router. If set to GLOBAL, this network's cloud routers will advertise routes with all subnetworks of this network, across regions. Possible values are: REGIONAL, GLOBAL | `string` | `"REGIONAL"` | no |
| <a name="input_subnet_bastion"></a> [subnet\_bastion](#input\_subnet\_bastion) | A subnet IP CIDR for the greenfield/test bastion host in the Management VPC. This value will be ignored if bastion\_enabled variable is set to false | `string` | `"10.0.0.0/24"` | no |
| <a name="input_subnet_cc_mgmt"></a> [subnet\_cc\_mgmt](#input\_subnet\_cc\_mgmt) | A subnet IP CIDR for the Cloud Connector in the Management VPC. This value will be ignored if byo\_mgmt\_subnet\_name is set to true | `string` | `"10.0.1.0/24"` | no |
| <a name="input_subnet_cc_service"></a> [subnet\_cc\_service](#input\_subnet\_cc\_service) | A subnet IP CIDR for the Cloud Connector/Load Balancer in the Service VPC. This value will be ignored if byo\_service\_subnet\_name is set to true | `string` | `"10.1.1.0/24"` | no |
| <a name="input_subnet_workload"></a> [subnet\_workload](#input\_subnet\_workload) | A subnet IP CIDR for the greenfield/test workload in the Service VPC. This value will be ignored if workloads\_enabled variable is set to false | `string` | `"10.1.2.0/24"` | no |
| <a name="input_workloads_enabled"></a> [workloads\_enabled](#input\_workloads\_enabled) | Configure Workload subnet in Service VPC with accompanying bastion host for SSH access to test client workloads if set to true | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_subnet"></a> [bastion\_subnet](#output\_bastion\_subnet) | Subnet for the bastion host |
| <a name="output_mgmt_subnet"></a> [mgmt\_subnet](#output\_mgmt\_subnet) | Subnet for the Cloud Connector Management subnet |
| <a name="output_mgmt_vpc_nat_gateway"></a> [mgmt\_vpc\_nat\_gateway](#output\_mgmt\_vpc\_nat\_gateway) | ID of Management VPC NAT Gateway resource |
| <a name="output_mgmt_vpc_network"></a> [mgmt\_vpc\_network](#output\_mgmt\_vpc\_network) | Cloud Connector Management VPC ID |
| <a name="output_service_subnet"></a> [service\_subnet](#output\_service\_subnet) | Subnet for the Cloud Connector Service subnet |
| <a name="output_service_vpc_nat_gateway"></a> [service\_vpc\_nat\_gateway](#output\_service\_vpc\_nat\_gateway) | ID of Management VPC NAT Gateway resource |
| <a name="output_service_vpc_network"></a> [service\_vpc\_network](#output\_service\_vpc\_network) | Cloud Connector Service VPC ID |
| <a name="output_workload_subnet"></a> [workload\_subnet](#output\_workload\_subnet) | Subnet for the workload host |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
