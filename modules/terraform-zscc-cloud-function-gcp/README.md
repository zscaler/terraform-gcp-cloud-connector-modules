<a href="https://terraform.io">
    <img src="https://raw.githubusercontent.com/hashicorp/terraform-website/master/public/img/logo-text.svg" alt="Terraform logo" title="Terraform" height="50" width="250" />
</a>
<a href="https://www.zscaler.com/">
    <img src="https://www.zscaler.com/themes/custom/zscaler/logo.svg" alt="Zscaler logo" title="Zscaler" height="50" width="250" />
</a>

# Zscaler Cloud Connector GCP Cloud Functions Terraform Module

This Terraform module deploys a comprehensive solution for monitoring and managing Zscaler Cloud Connector instances within a Google Cloud Platform (GCP) environment. It sets up two primary Google Cloud Functions (Gen 2) that provide automated health monitoring, instance remediation, and resource synchronization between GCP and the Zscaler Cloud.

## Purpose

The primary goal of this module is to ensure the high availability and operational consistency of Zscaler Cloud Connector deployments in GCP, particularly those managed by autoscaling groups. It achieves this through two key functions:

1.  **Health Monitoring**: A `health-monitor-function` runs every minute to check the health of Cloud Connector instances using custom metrics. It can automatically remove unhealthy instances from Managed Instance Groups (MIGs), allowing the MIG to replace them with healthy ones. This maintains the integrity and performance of the traffic forwarding service.

2.  **Resource Synchronization**: A `resource-sync-function` runs periodically (every 30 minutes) to reconcile the list of virtual machine instances between your GCP project and the Zscaler Cloud Connector Portal. It automatically removes any "dangling" VM resources from the Zscaler portal that no longer exist in GCP, ensuring a clean and accurate configuration.

## Resources Created

This module provisions the following GCP resources to support the monitoring and synchronization functions:

-   **Google Cloud Storage Bucket**: A GCS bucket is created to store the packaged Python source code for the Cloud Functions. You also have the option to provide an existing bucket.
-   **Google Cloud Storage Object**: The Python source code, which must be located in the `zscaler-cc-cloud-run-function/` subdirectory within this module, is zipped and uploaded to the GCS bucket.
-   **Google IAM Service Account**: A dedicated service account is created for the Cloud Functions to operate under the principle of least privilege. You can also provide an existing service account.
-   **Google Project IAM Bindings**: The service account is granted the necessary roles to perform its tasks:
    -   `Compute Instance Admin (v1)`: To manage VM instances (i.e., delete unhealthy ones from MIGs).
    -   `Monitoring Viewer`: To read health metrics from Google Cloud Monitoring.
    -   `Logs Writer`: To write execution logs for debugging and auditing.
    -   `Cloud Functions Invoker`: To allow Cloud Scheduler to trigger the functions securely.
-   **Google Cloud Functions (Gen 2)**: Two serverless functions are deployed:
    -   `health-monitor-function`: For automated health checks and instance remediation.
    -   `resource-sync-function`: For GCP-to-Zscaler resource reconciliation.
-   **Google Cloud Scheduler Jobs**: (Optional, enabled by default) Two scheduler jobs are created to invoke the functions automatically on a recurring basis:
    -   `health-monitor-job`: Runs every minute (`* * * * *`).
    -   `resource-sync-job`: Runs every 30 minutes (`*/30 * * * *`).

## Usage Example

```terraform
module "cc_functions" {
  source = "./modules/terraform-zscc-cloud-function-gcp"

  name_prefix         = "zscc"
  resource_tag        = "prod"
  project             = "your-gcp-project-id"
  region              = "us-central1"
  storage_bucket_name = "your-unique-bucket-name-for-functions"
  cc_vm_prov_url      = "https://connector.zscaler.com/api/v1/provUrl/..."
  secret_name         = "your-zscaler-api-secret-name"
  instance_groups     = ["zscc-mig-1", "zscc-mig-2"]
  
  # Pass other required variables for function environment
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.7, < 2.0.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 5.11.0, < 7 |
| <a name="requirement_http"></a> [http](#requirement\_http) | >= 3.5.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 5.11.0, < 7 |
| <a name="provider_time"></a> [time](#provider\_time) | >= 0.9.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_cloud_scheduler_job.health_monitor](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_scheduler_job) | resource |
| [google_cloud_scheduler_job.resource_sync](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_scheduler_job) | resource |
| [google_cloudfunctions2_function.health_monitor_function](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions2_function) | resource |
| [google_cloudfunctions2_function.resource_sync_function](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions2_function) | resource |
| [google_project_iam_member.cloud_function_instance_admin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.cloud_function_logging_writer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.cloud_function_monitoring_viewer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.cloud_run_invoker](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_secret_manager_secret_iam_member.cloud_run_secrets_accessor](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_member) | resource |
| [google_service_account.service_account_function](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_storage_bucket.cc_storage_bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_object.upload_cloud_function_zip_object](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object) | resource |
| [time_sleep.wait_60s](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [google_service_account.service_account_function_selected](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/service_account) | data source |
| [google_storage_bucket.existing_storage_bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/storage_bucket) | data source |
| [google_storage_bucket_object.existing_cloud_function_zip_object](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/storage_bucket_object) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_byo_function_service_account"></a> [byo\_function\_service\_account](#input\_byo\_function\_service\_account) | "Customer provided existing Service Account ID. If set, module will use this instead of trying to create a new one<br/> - The name of the service account within the project (e.g. my-service)<br/> - The fully-qualified path to a service account resource (e.g. projects/my-project/serviceAccounts/...)<br/> - The email address of the service account (e.g. my-service@my-project.iam.gserviceaccount.com)" | `string` | `""` | no |
| <a name="input_byo_storage_bucket"></a> [byo\_storage\_bucket](#input\_byo\_storage\_bucket) | Set to True if you wish to use an existing Storage Bucket to associate with the Cloud Run Function. Default is false meaning Terraform module will create a new one | `bool` | `false` | no |
| <a name="input_cc_vm_prov_url"></a> [cc\_vm\_prov\_url](#input\_cc\_vm\_prov\_url) | Zscaler Cloud Connector Provisioning URL | `string` | n/a | yes |
| <a name="input_cloud_function_service_account_display_name"></a> [cloud\_function\_service\_account\_display\_name](#input\_cloud\_function\_service\_account\_display\_name) | Custom Service Account display name string for Cloud Run Function | `string` | `""` | no |
| <a name="input_cloud_function_service_account_id"></a> [cloud\_function\_service\_account\_id](#input\_cloud\_function\_service\_account\_id) | Custom Service Account ID string for Cloud Run Function | `string` | `""` | no |
| <a name="input_cloud_function_source_object_name"></a> [cloud\_function\_source\_object\_name](#input\_cloud\_function\_source\_object\_name) | Name of existing Storage Bucket Object (zip file) name. Defaults to zscaler\_cc\_cloud\_run\_function.zip. Only change if you have renamed the file/path for an existing storage bucket | `string` | `"zscaler_cc_cloud_run_function.zip"` | no |
| <a name="input_cloud_function_source_object_path"></a> [cloud\_function\_source\_object\_path](#input\_cloud\_function\_source\_object\_path) | By default, this Terraform module will download the latest version of the Cloud Run Function ZIP and save it to the root/function\_zip directory. If upload\_cloud\_function\_ip is set to true, this variable path will be used as the source to upload the zip file to the specified Storage Bucket | `string` | `""` | no |
| <a name="input_consecutive_unhealthy_threshold"></a> [consecutive\_unhealthy\_threshold](#input\_consecutive\_unhealthy\_threshold) | Consecutive unhealthy metrics threshold (sustained issues) | `number` | `5` | no |
| <a name="input_data_points_eval_period"></a> [data\_points\_eval\_period](#input\_data\_points\_eval\_period) | How many data points (minutes) function should look back for health reference calculations | `number` | `10` | no |
| <a name="input_enable_scheduler"></a> [enable\_scheduler](#input\_enable\_scheduler) | Whether to create Cloud Scheduler jobs | `bool` | `true` | no |
| <a name="input_instance_group_names"></a> [instance\_group\_names](#input\_instance\_group\_names) | List of MIG friendly names for automatic zone/VPC discovery | `list(string)` | n/a | yes |
| <a name="input_missing_metrics_critical_threshold_min"></a> [missing\_metrics\_critical\_threshold\_min](#input\_missing\_metrics\_critical\_threshold\_min) | Missing metrics critical threshold (minutes) | `number` | `5` | no |
| <a name="input_missing_metrics_termination_threshold_min"></a> [missing\_metrics\_termination\_threshold\_min](#input\_missing\_metrics\_termination\_threshold\_min) | Missing metrics termination threshold (minutes) | `number` | `10` | no |
| <a name="input_missing_metrics_warning_threshold_min"></a> [missing\_metrics\_warning\_threshold\_min](#input\_missing\_metrics\_warning\_threshold\_min) | Missing metrics warning threshold (minutes) | `number` | `2` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A prefix to associate to all the Cloud Connector module resources | `string` | `null` | no |
| <a name="input_project"></a> [project](#input\_project) | Google Cloud project name | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Google Cloud region | `string` | n/a | yes |
| <a name="input_resource_tag"></a> [resource\_tag](#input\_resource\_tag) | A tag to associate to all the Cloud Connector module resources | `string` | `null` | no |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | The runtime in which to run the function | `string` | `"python312"` | no |
| <a name="input_secret_name"></a> [secret\_name](#input\_secret\_name) | GCP Secret Manager friendly name. Not required if using HashiCorp Vault | `string` | `""` | no |
| <a name="input_storage_bucket_location"></a> [storage\_bucket\_location](#input\_storage\_bucket\_location) | *Optional if var.byo\_storage\_bucket is true*. Location for the Storage Bucket. Must be a multi-region or dual-region location. See https://cloud.google.com/storage/docs/locations for more details | `string` | `"US"` | no |
| <a name="input_storage_bucket_name"></a> [storage\_bucket\_name](#input\_storage\_bucket\_name) | Name of either the existing Storage Bucket name if var.byo\_storage\_bucket is true, or the new Storage Bucket name if var.byo\_storage\_bucket is false. | `string` | n/a | yes |
| <a name="input_sync_dry_run"></a> [sync\_dry\_run](#input\_sync\_dry\_run) | Whether to run sync in dry-run mode | `bool` | `false` | no |
| <a name="input_sync_excluded_instances"></a> [sync\_excluded\_instances](#input\_sync\_excluded\_instances) | GCP instance IDs to never delete from Zscaler | `list(string)` | `[]` | no |
| <a name="input_sync_max_deletions_per_run"></a> [sync\_max\_deletions\_per\_run](#input\_sync\_max\_deletions\_per\_run) | Maximum Cloud Connector VMs that can be deleted per sync run | `number` | `16` | no |
| <a name="input_unhealthy_metric_threshold"></a> [unhealthy\_metric\_threshold](#input\_unhealthy\_metric\_threshold) | Total unhealthy metrics in eval window defined in data\_points\_eval\_period (chronic issues) | `number` | `7` | no |
| <a name="input_uniform_bucket_level_access"></a> [uniform\_bucket\_level\_access](#input\_uniform\_bucket\_level\_access) | Whether to enable Uniform bucket-level access to the Storage Bucket. When you enable uniform bucket-level access on a bucket, Access Control Lists (ACLs) are disabled, and only bucket-level Identity and Access Management (IAM) permissions grant access to that bucket and the objects it contains | `bool` | `true` | no |
| <a name="input_upload_cloud_function_zip"></a> [upload\_cloud\_function\_zip](#input\_upload\_cloud\_function\_zip) | By default, this Terraform module will create a new Storage Bucket and upload the zip file to it. Setting this value to false will prevent creating the bucket object and uploading the zip file | `bool` | `true` | no |
| <a name="input_zscaler_user_agent"></a> [zscaler\_user\_agent](#input\_zscaler\_user\_agent) | Custom User-Agent for Zscaler API requests | `string` | `"GCP-HealthMonitor/1.0 (Function: resource-sync)"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_health_monitor_function_id"></a> [health\_monitor\_function\_id](#output\_health\_monitor\_function\_id) | ID of the Cloud Function (Gen 2) |
| <a name="output_health_monitor_function_uri"></a> [health\_monitor\_function\_uri](#output\_health\_monitor\_function\_uri) | URI of the Cloud Function (Gen 2) |
| <a name="output_resource_sync_function_id"></a> [resource\_sync\_function\_id](#output\_resource\_sync\_function\_id) | ID of the resource sync function |
| <a name="output_resource_sync_function_uri"></a> [resource\_sync\_function\_uri](#output\_resource\_sync\_function\_uri) | URI of the Cloud Function (Gen 2) |
| <a name="output_scheduler_jobs"></a> [scheduler\_jobs](#output\_scheduler\_jobs) | Names of created scheduler jobs |
| <a name="output_storage_bucket_name"></a> [storage\_bucket\_name](#output\_storage\_bucket\_name) | Name of the Storage Bucket used for Cloud Function source code |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
