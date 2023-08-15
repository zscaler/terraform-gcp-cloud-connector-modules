# Zscaler Cloud Connector / GCP Compute Instance (Cloud Connector) Module

This module creates all resource dependencies required to configure and deploy Cloud Connector appliances resliently in Google Cloud including: 1x GCP Compute Template and 1x Instance Groups per availability zone specified. Each Instance Group has a target_size input per variable "cc_count" that specifies how many Cloud Connectors should be deployed in EACH Instance Group.

## Considerations
Zscaler recommends deploying Cloud Connectors via consistent/reusable templates with Compute Instances managed by Zonal Instance Groups. The Cloud Connector health is managed and monitored via the Internal Network Load Balancer (ILB). Zscaler does not currently support utilizing GCP specific features of Managed Instance Groups like Instance based Autohealing or Autoscaling with this deployment module.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.7, < 2.0.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 4.70.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.2.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.9.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | ~> 4.70.0 |
| <a name="provider_time"></a> [time](#provider\_time) | ~> 0.9.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_instance_group_manager.cc_instance_group_manager](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_group_manager) | resource |
| [google_compute_instance_template.cc_instance_template](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template) | resource |
| [time_sleep.wait_60_seconds](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [google_compute_instance.cc_vm_instances](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_instance) | data source |
| [google_compute_instance_group.cc_instance_groups](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_instance_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cc_count"></a> [cc\_count](#input\_cc\_count) | Default number of Cloud Connector appliances to create | `number` | `1` | no |
| <a name="input_ccvm_instance_type"></a> [ccvm\_instance\_type](#input\_ccvm\_instance\_type) | Cloud Connector Instance Type | `string` | `"n2-standard-2"` | no |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | Custom image name to be used for deploying Cloud Connector appliances. Ideally all VMs should be on the same Image as templates always pull the latest from Google Marketplace. This variable is provided if a customer desires to override/retain an old ami for existing deployments rather than upgrading and forcing a replacement. It is also inputted as a list to facilitate if a customer desired to manually upgrade select CCs deployed based on the cc\_count index | `string` | `""` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A prefix to associate to all the Cloud Connector module resources | `string` | `null` | no |
| <a name="input_project"></a> [project](#input\_project) | Google Cloud project name | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Google Cloud region | `string` | n/a | yes |
| <a name="input_resource_tag"></a> [resource\_tag](#input\_resource\_tag) | A tag to associate to all the Cloud Connector module resources | `string` | `null` | no |
| <a name="input_service_account"></a> [service\_account](#input\_service\_account) | IAM Service Account Email to be assigned to each Cloud Connector instance | `string` | n/a | yes |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | A public key uploaded to the Cloud Connector instances | `string` | n/a | yes |
| <a name="input_update_max_unavailable_fixed"></a> [update\_max\_unavailable\_fixed](#input\_update\_max\_unavailable\_fixed) | The maximum number of instances that can be unavailable during the update process. Conflicts with max\_unavailable\_percent. If neither is set, defaults to 1 | `number` | `1` | no |
| <a name="input_update_policy_max_surge_fixed"></a> [update\_policy\_max\_surge\_fixed](#input\_update\_policy\_max\_surge\_fixed) | The maximum number of instances that can be created above the specified targetSize during the update process. Conflicts with max\_surge\_percent. If neither is set, defaults to 1 | `number` | `1` | no |
| <a name="input_update_policy_replacement_method"></a> [update\_policy\_replacement\_method](#input\_update\_policy\_replacement\_method) | The instance replacement method for managed instance groups. Valid values are: RECREATE or SUBSTITUTE. If SUBSTITUTE (default), the group replaces VM instances with new instances that have randomly generated names. If RECREATE, instance names are preserved. You must also set max\_unavailable\_fixed or max\_unavailable\_percent to be greater than 0 | `string` | `"SUBSTITUTE"` | no |
| <a name="input_update_policy_type"></a> [update\_policy\_type](#input\_update\_policy\_type) | The type of update process. You can specify either PROACTIVE so that the instance group manager proactively executes actions in order to bring instances to their target versions or OPPORTUNISTIC so that no action is proactively executed but the update will be performed as part of other actions (for example, resizes or recreateInstances calls) | `string` | `"OPPORTUNISTIC"` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | Cloud Init data | `string` | n/a | yes |
| <a name="input_vpc_subnetwork_ccvm_mgmt"></a> [vpc\_subnetwork\_ccvm\_mgmt](#input\_vpc\_subnetwork\_ccvm\_mgmt) | VPC subnetwork for CC VM MGMT | `string` | n/a | yes |
| <a name="input_vpc_subnetwork_ccvm_service"></a> [vpc\_subnetwork\_ccvm\_service](#input\_vpc\_subnetwork\_ccvm\_service) | VPC subnetwork for CC VM service | `string` | n/a | yes |
| <a name="input_zones"></a> [zones](#input\_zones) | Availability zone names | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cc_forwarding_ip"></a> [cc\_forwarding\_ip](#output\_cc\_forwarding\_ip) | CC VM internal forwarding IP |
| <a name="output_cc_instance"></a> [cc\_instance](#output\_cc\_instance) | CC VM name |
| <a name="output_cc_management_ip"></a> [cc\_management\_ip](#output\_cc\_management\_ip) | CC VM internal management IP |
| <a name="output_instance_group_ids"></a> [instance\_group\_ids](#output\_instance\_group\_ids) | Name for Instance Groups |
| <a name="output_instance_group_names"></a> [instance\_group\_names](#output\_instance\_group\_names) | Name for Instance Groups |
| <a name="output_instance_group_zones"></a> [instance\_group\_zones](#output\_instance\_group\_zones) | GCP Zone assigmnents for Instance Groups |
| <a name="output_instance_template_forwarding_vpc"></a> [instance\_template\_forwarding\_vpc](#output\_instance\_template\_forwarding\_vpc) | GCP VPC for Compute Instance Template VM forwarding interfaces |
| <a name="output_instance_template_management_vpc"></a> [instance\_template\_management\_vpc](#output\_instance\_template\_management\_vpc) | GCP VPC for Compute Instance Template VM management interface |
| <a name="output_instance_template_project"></a> [instance\_template\_project](#output\_instance\_template\_project) | GCP Project for Compute Instance Template and resource placement |
| <a name="output_instance_template_region"></a> [instance\_template\_region](#output\_instance\_template\_region) | GCP Region for Compute Instance Template and resource placement |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
