# Zscaler Cloud Connector / GCP Service Account/IAM Module

This module creates a new Service Account in the default/current project and assigns it roles/secretmanager.secretAccessor permissions for the Cloud Connectors to be able to retrieve Secret Manager values. The generated service account principal is provided as an output for the cc_vm module to attach to the Cloud Connector instances to use.


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.7, < 2.0.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 5.11.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 5.11.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_project_iam_member.ccvm_sa_pubsub_editor](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_secret_manager_secret_iam_member.member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_member) | resource |
| [google_service_account.service_account_ccvm](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_member.iam_token_creator](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |
| [google_service_account.service_account_ccvm_selected](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/service_account) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_byo_ccvm_service_account"></a> [byo\_ccvm\_service\_account](#input\_byo\_ccvm\_service\_account) | "Customer provided existing Service Account ID. If set, module will use this instead of trying to create a new one<br> - The name of the service account within the project (e.g. my-service)<br> - The fully-qualified path to a service account resource (e.g. projects/my-project/serviceAccounts/...)<br> - The email address of the service account (e.g. my-service@my-project.iam.gserviceaccount.com)" | `string` | `""` | no |
| <a name="input_grant_pubsub_editor"></a> [grant\_pubsub\_editor](#input\_grant\_pubsub\_editor) | If true, grant roles/pubsub.editor to the CCVM SA at project scope | `bool` | `false` | no |
| <a name="input_hcp_vault_enabled"></a> [hcp\_vault\_enabled](#input\_hcp\_vault\_enabled) | Enable a specific outbound firewall rule for Cloud Connector to be able to establish connectivity to customer provided HCP Vault address. Default is false | `bool` | `false` | no |
| <a name="input_project"></a> [project](#input\_project) | Google Cloud project name | `string` | n/a | yes |
| <a name="input_secret_name"></a> [secret\_name](#input\_secret\_name) | GCP Secret Manager friendly name. Not required if using byo\_service\_account\_id or HashiCorp Vault | `string` | `""` | no |
| <a name="input_service_account_display_name"></a> [service\_account\_display\_name](#input\_service\_account\_display\_name) | Custom Service Account display name string for Cloud Connector | `string` | `""` | no |
| <a name="input_service_account_id"></a> [service\_account\_id](#input\_service\_account\_id) | Custom Service Account ID string for Cloud Connector | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_service_account"></a> [service\_account](#output\_service\_account) | CC VM Service Account Principal |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
