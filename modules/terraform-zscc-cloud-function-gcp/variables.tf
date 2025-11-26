variable "name_prefix" {
  type        = string
  description = "A prefix to associate to all the Cloud Connector module resources"
  default     = null
}

variable "resource_tag" {
  type        = string
  description = "A tag to associate to all the Cloud Connector module resources"
  default     = null
}

variable "project" {
  type        = string
  description = "Google Cloud project name"
}

variable "region" {
  type        = string
  description = "Google Cloud region"
}

variable "runtime" {
  description = "The runtime in which to run the function"
  type        = string
  default     = "python312"

  validation {
    condition     = contains(["python311", "python312"], var.runtime)
    error_message = "Invalid architecture. Must be either 'python311' or 'python312'."
  }
}

variable "enable_scheduler" {
  description = "Whether to create Cloud Scheduler jobs"
  type        = bool
  default     = true
}

variable "byo_storage_bucket" {
  type        = bool
  description = "Set to True if you wish to use an existing Storage Bucket to associate with the Cloud Run Function. Default is false meaning Terraform module will create a new one"
  default     = false
}

variable "storage_bucket_name" {
  type        = string
  description = "Name of either the existing Storage Bucket name if var.byo_storage_bucket is true, or the new Storage Bucket name if var.byo_storage_bucket is false."
}

variable "storage_bucket_location" {
  type        = string
  description = "*Optional if var.byo_storage_bucket is true*. Location for the Storage Bucket. Must be a multi-region or dual-region location. See https://cloud.google.com/storage/docs/locations for more details"
  default     = "US"
}

variable "upload_cloud_function_zip" {
  type        = bool
  description = "By default, this Terraform module will create a new Storage Bucket and upload the zip file to it. Setting this value to false will prevent creating the bucket object and uploading the zip file"
  default     = true
}

variable "cloud_function_source_object_path" {
  type        = string
  description = "By default, this Terraform module will download the latest version of the Cloud Run Function ZIP and save it to the root/function_zip directory. If upload_cloud_function_ip is set to true, this variable path will be used as the source to upload the zip file to the specified Storage Bucket"
  default     = ""
}

variable "cloud_function_source_object_name" {
  type        = string
  description = "Name of existing Storage Bucket Object (zip file) name. Defaults to zscaler_cc_cloud_run_function.zip. Only change if you have renamed the file/path for an existing storage bucket"
  default     = "zscaler_cc_cloud_run_function.zip"
}

variable "uniform_bucket_level_access" {
  type        = bool
  description = "Whether to enable Uniform bucket-level access to the Storage Bucket. When you enable uniform bucket-level access on a bucket, Access Control Lists (ACLs) are disabled, and only bucket-level Identity and Access Management (IAM) permissions grant access to that bucket and the objects it contains"
  default     = true
}


# Cloud Function Environment Variable Configuration
variable "instance_group_names" {
  description = "List of MIG friendly names for automatic zone/VPC discovery"
  type        = list(string)
}

variable "sync_dry_run" {
  description = "Whether to run sync in dry-run mode"
  type        = bool
  default     = false
}

variable "sync_max_deletions_per_run" {
  description = "Maximum Cloud Connector VMs that can be deleted per sync run"
  type        = number
  default     = 1
}

variable "sync_excluded_instances" {
  description = "GCP instance IDs to never delete from Zscaler"
  type        = list(string)
  default     = []
}

variable "missing_metrics_warning_threshold_min" {
  description = "Missing metrics warning threshold (minutes)"
  type        = number
  default     = 2
}

variable "missing_metrics_critical_threshold_min" {
  description = "Missing metrics critical threshold (minutes)"
  type        = number
  default     = 5
}

variable "missing_metrics_termination_threshold_min" {
  description = "Missing metrics termination threshold (minutes)"
  type        = number
  default     = 30
}

variable "unhealthy_metric_threshold" {
  description = "Total unhealthy metrics in 30min window (chronic issues)"
  type        = number
  default     = 12
}

variable "consecutive_unhealthy_threshold" {
  description = "Consecutive unhealthy metrics threshold (sustained issues)"
  type        = number
  default     = 7
}

variable "zscaler_user_agent" {
  description = "Custom User-Agent for Zscaler API requests"
  type        = string
  default     = "GCP-HealthMonitor/1.0 (Function: resource-sync)"
}

variable "cc_vm_prov_url" {
  type        = string
  description = "Zscaler Cloud Connector Provisioning URL"
}

variable "secret_name" {
  type        = string
  description = "GCP Secret Manager friendly name. Not required if using HashiCorp Vault"
  default     = ""
}

variable "byo_function_service_account" {
  type        = string
  description = <<-EOT
  "Customer provided existing Service Account ID. If set, module will use this instead of trying to create a new one
   - The name of the service account within the project (e.g. my-service)
   - The fully-qualified path to a service account resource (e.g. projects/my-project/serviceAccounts/...)
   - The email address of the service account (e.g. my-service@my-project.iam.gserviceaccount.com)"
EOT
  default     = ""
}

variable "cloud_function_service_account_id" {
  type        = string
  description = "Custom Service Account ID string for Cloud Run Function"
  default     = ""
}

variable "cloud_function_service_account_display_name" {
  type        = string
  description = "Custom Service Account display name string for Cloud Run Function"
  default     = ""
}


# Version manifest (latest version info)
#https://zscaler-cc-functions-artifacts.s3.amazonaws.com/zscaler-cc-functions/version-manifest.json

# Latest artifact
#https://zscaler-cc-functions-artifacts.s3.amazonaws.com/zscaler-cc-functions/latest/cloud-functions-latest.zip

# Specific version
#https://zscaler-cc-functions-artifacts.s3.amazonaws.com/zscaler-cc-functions/releases/v1.2.3/cloud-functions-v1.2.3.zip
