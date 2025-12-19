variable "name_prefix" {
  type        = string
  description = "The name prefix for all your resources"
  default     = "zscc"
  validation {
    condition     = length(var.name_prefix) <= 12
    error_message = "Variable name_prefix must be 12 or less characters."
  }
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]+$", var.name_prefix))
    error_message = "Variable name_prefix using invalid characters."
  }
}

variable "credentials" {
  type        = string
  description = "Path to the service account json file for terraform to authenticate to Google Cloud"
}

variable "project" {
  type        = string
  description = "Google Cloud project name"
}

variable "project_host" {
  type        = string
  description = "Google Cloud Host Project name. Defaults to null. This variable is intended for environments where different resources might exist in separate host and service projects"
  default     = null
}

variable "region" {
  type        = string
  description = "Google Cloud region"
}

variable "bastion_ssh_allow_ip" {
  type        = list(string)
  description = "CIDR blocks of trusted networks for bastion host ssh access from Internet"
  default     = ["0.0.0.0/0"]
}

variable "default_nsg" {
  type        = list(string)
  description = "Default CIDR list to permit workload traffic destined for Cloud Connector"
  default     = ["0.0.0.0/0"]
}

variable "allowed_ports" {
  type        = list(string)
  description = "A list of ports to permit inbound to Cloud Connector Service VPC. Default empty list means to allow all."
  default     = []
}

variable "subnet_bastion" {
  type        = string
  description = "A subnet IP CIDR for the greenfield/test bastion host in the Management VPC"
  default     = "10.0.0.0/24"
}

variable "subnet_workload" {
  type        = string
  description = "A subnet IP CIDR for the greenfield/test workload in the Service VPC"
  default     = "10.1.2.0/24"
}

variable "subnet_cc_mgmt" {
  type        = string
  description = "A subnet IP CIDR for the Cloud Connector in the Management VPC"
  default     = "10.0.1.0/24"
}

variable "subnet_cc_service" {
  type        = string
  description = "A subnet IP CIDR for the Cloud Connector/Load Balancer in the Service VPC"
  default     = "10.1.1.0/24"
}

variable "ccvm_instance_type" {
  type        = string
  description = "Cloud Connector Instance Type"
  default     = "n2-standard-2"
  validation {
    condition = (
      var.ccvm_instance_type == "e2-standard-2" ||
      var.ccvm_instance_type == "e2-standard-4" ||
      var.ccvm_instance_type == "e2-standard-8" ||
      var.ccvm_instance_type == "n2-standard-2" ||
      var.ccvm_instance_type == "n2-standard-4" ||
      var.ccvm_instance_type == "n2-standard-8" ||
      var.ccvm_instance_type == "n2d-standard-2" ||
      var.ccvm_instance_type == "n2d-standard-4" ||
      var.ccvm_instance_type == "n2d-standard-8"
    )
    error_message = "Input ccvm_instance_type must be set to an approved vm instance type."
  }
}

variable "secret_name" {
  type        = string
  description = "GCP Secret Manager friendly name. Not required if using HashiCorp Vault"
  default     = ""
}

variable "cc_vm_prov_url" {
  type        = string
  description = "Zscaler Cloud Connector Provisioning URL"
}

variable "http_probe_port" {
  type        = number
  description = "Port number for Cloud Connector cloud init to enable listener port for HTTP probe from GCP LB"
  default     = 50000
  validation {
    condition = (
      tonumber(var.http_probe_port) == 80 ||
      (tonumber(var.http_probe_port) >= 1024 && tonumber(var.http_probe_port) <= 65535)
    )
    error_message = "Input http_probe_port must be set to a single value of 80 or any number between 1024-65535."
  }
}

variable "tls_key_algorithm" {
  type        = string
  description = "algorithm for tls_private_key resource"
  default     = "RSA"
}

variable "az_count" {
  type        = number
  description = "Default number zonal instance groups to create based on availability zone"
  default     = 2
  validation {
    condition = (
      (var.az_count >= 1 && var.az_count <= 3)
    )
    error_message = "Input az_count must be set to a single value between 1 and 3. Note* some regions have greater than 3 AZs. Please modify az_count validation in variables.tf if you are utilizing more than 3 AZs in a region that supports it."
  }
}

variable "zones" {
  type        = list(string)
  description = "(Optional) Availability zone names. Only required if automatic zones selection based on az_count is undesirable"
  default     = []
}

variable "image_name" {
  type        = string
  description = "Custom image name to be used for deploying Cloud Connector appliances. Ideally all VMs should be on the same Image as templates always pull the latest from Google Marketplace. This variable is provided if a customer desires to override/retain an old ami for existing deployments rather than upgrading and forcing a replacement. It is also inputted as a list to facilitate if a customer desired to manually upgrade select CCs deployed based on the cc_count index"
  default     = ""
}

variable "health_check_interval" {
  type        = number
  description = "Interval for ILB health check probing, in seconds, of Cloud Connector targets"
  default     = 10
}

variable "healthy_threshold" {
  type        = number
  description = "The number of successful health checks required before an unhealthy target becomes healthy. Minimum 2 and maximum 10"
  default     = 2
}

variable "unhealthy_threshold" {
  type        = number
  description = "The number of unsuccessful health checks required before an healthy target becomes unhealthy. Minimum 2 and maximum 10"
  default     = 3
}

variable "session_affinity" {
  type        = string
  description = "Controls the distribution of new connections from clients to the load balancer's backend VMs"
  default     = "CLIENT_IP_PROTO"
  validation {
    condition = (
      var.session_affinity == "CLIENT_IP_NO_DESTINATION" ||
      var.session_affinity == "CLIENT_IP" ||
      var.session_affinity == "CLIENT_IP_PROTO" ||
      var.session_affinity == "NONE"
    )
    error_message = "Input session_affinity must be set to either CLIENT_IP_NO_DESTINATION, CLIENT_IP, CLIENT_IP_PROTO, or NONE."
  }
}

variable "allow_global_access" {
  type        = bool
  description = "true: Clients can access ILB from all regions; false: Only allow access from clients in the same region as the internal load balancer."
  default     = false
}

variable "support_access_enabled" {
  type        = bool
  description = "Enable a specific outbound firewall rule for Cloud Connector to be able to establish connectivity for Zscaler support access. Default is true"
  default     = true
}

variable "workload_count" {
  type        = number
  description = "The number of Workload VMs to deploy"
  default     = 2
  validation {
    condition     = var.workload_count >= 1 && var.workload_count <= 250
    error_message = "Input workload_count must be a whole number between 1 and 250."
  }
}


## Custom name specifications. For granular deployments where autoname generation is not desirable

variable "service_account_id" {
  type        = string
  description = "Custom Service Account ID string for Cloud Connector"
  default     = null
}

variable "service_account_display_name" {
  type        = string
  description = "Custom Service Account display name string for Cloud Connector"
  default     = null
}

variable "instance_template_name_prefix" {
  type        = string
  description = "Creates a unique Instance Template name beginning with the specified prefix. Conflicts with variable instance_template_name"
  default     = ""
}

variable "instance_template_name" {
  type        = string
  description = "The name of the instance template. Conflicts with variable instance_template_name_prefix"
  default     = ""
}

variable "instance_group_name" {
  type        = list(string)
  description = "The name of the Instance Group Manager. Must be 1-63 characters long and comply with RFC1035. Supported characters include lowercase letters, numbers, and hyphens"
  default     = [""]
}

variable "base_instance_name" {
  type        = list(string)
  description = "The base instance name to use for instances in this group. The value must be a valid RFC1035 name. Supported characters are lowercase letters, numbers, and hyphens (-). Instances are named by appending a hyphen and a random four-character string to the base instance name"
  default     = [""]
}

variable "ilb_backend_service_name" {
  type        = string
  description = "Name of the resource. Provided by the client when the resource is created. The name must be 1-63 characters long, and comply with RFC1035. Specifically, the name must be 1-63 characters long and match the regular expression [a-z]([-a-z0-9]*[a-z0-9])? which means the first character must be a lowercase letter, and all following characters must be a dash, lowercase letter, or digit, except the last character, which cannot be a dash"
  default     = null
}

variable "ilb_health_check_name" {
  type        = string
  description = "Name of the resource. Provided by the client when the resource is created. The name must be 1-63 characters long, and comply with RFC1035. Specifically, the name must be 1-63 characters long and match the regular expression [a-z]([-a-z0-9]*[a-z0-9])? which means the first character must be a lowercase letter, and all following characters must be a dash, lowercase letter, or digit, except the last character, which cannot be a dash"
  default     = null
}

variable "ilb_frontend_ip_name" {
  type        = string
  description = "Name of the resource. The name must be 1-63 characters long, and comply with RFC1035. Specifically, the name must be 1-63 characters long and match the regular expression [a-z]([-a-z0-9]*[a-z0-9])? which means the first character must be a lowercase letter, and all following characters must be a dash, lowercase letter, or digit, except the last character, which cannot be a dash"
  default     = null
}

variable "ilb_forwarding_rule_name" {
  type        = string
  description = "Name of the resource; provided by the client when the resource is created. The name must be 1-63 characters long, and comply with RFC1035. Specifically, the name must be 1-63 characters long and match the regular expression [a-z]([-a-z0-9]*[a-z0-9])? which means the first character must be a lowercase letter, and all following characters must be a dash, lowercase letter, or digit, except the last character, which cannot be a dash"
  default     = null
}

variable "fw_ilb_health_check_name" {
  type        = string
  description = "Name of the firewall rule created with ILB permitting GCP health check probe source ranges on the configured HTTP probe port inbound to the Cloud Connector service interface(s)"
  default     = null
}

variable "fw_cc_mgmt_ssh_ingress_name" {
  type        = string
  description = "The name of the compute firewall created on the user defined Cloud Connector Management VPC Network permitting SSH inbound from the VPC CIDR range by default"
  default     = null
}

variable "fw_cc_service_default_name" {
  type        = string
  description = "The name of the compute firewall created on the user defined Cloud Connector Service VPC Network permitting workload traffic to be sent to Zscaler"
  default     = null
}

variable "fw_cc_mgmt_zssupport_tunnel_name" {
  type        = string
  description = "The name of the compute firewall created on the user defined Cloud Connector Management VPC Network permitting CC to establish zssupport tunnel"
  default     = null
}

variable "fw_cc_mgmt_hcp_vault_address_name" {
  type        = string
  description = "The name of the compute firewall created on the user defined Cloud Connector Management VPC Network permitting CC to access to HCP Vault Address port number"
  default     = null
}

variable "hcp_vault_enabled" {
  type        = bool
  description = "True/False used to determine specific HCP Vault configured network firewall and Service Account IAM roles. Default is false"
  default     = false
}

variable "hcp_vault_address" {
  type        = string
  description = "Customer managed HashiCorp Vault URL; including leading https (if applicable) and trailing port number"
  default     = ""
}

variable "hcp_vault_secret_path" {
  type        = string
  description = "Customer managed HashiCorp Vault secret path. The path to a secret is formed from three parts: <namespace>/<engine mount point>/<path to secret>. If you are not using the enterprise version of Vault, you should omit the first part"
  default     = ""
}

variable "hcp_vault_role_name" {
  type        = string
  description = "Customer managed HashiCorp Role Name"
  default     = ""
}

variable "hcp_gcp_auth_role_type" {
  type        = string
  description = "Customer managed HashiCorp Vault GCP Auth Method"
  default     = "gcp_iam"
}

variable "hcp_vault_ips" {
  type        = list(string)
  description = "Default CIDR list to permit Cloud Connector traffic destined for customer defined HCP Vault address(es)"
  default     = ["0.0.0.0/0"]
}

variable "hcp_vault_port" {
  type        = string
  description = "Default TCP Port Number for customer defined HCP Vault address(es)"
  default     = "8200"
}

variable "byo_ccvm_service_account" {
  type        = string
  description = <<-EOT
  "Customer provided existing Service Account ID. If set, module will use this instead of trying to create a new one
   - The name of the service account within the project (e.g. my-service)
   - The fully-qualified path to a service account resource (e.g. projects/my-project/serviceAccounts/...)
   - The email address of the service account (e.g. my-service@my-project.iam.gserviceaccount.com)"
EOT
  default     = ""
}

variable "autoscaling_enabled" {
  type        = bool
  default     = true
  description = "Enable autoscaling for the instance group"
}

variable "autoscaling_name" {
  type        = list(string)
  description = "The name of the Autoscaling Policy. Must be 1-63 characters long and comply with RFC1035. Supported characters include lowercase letters, numbers, and hyphens"
  default     = [""]
}

variable "max_replicas" {
  type        = number
  description = "The maximum number of replicas for the autoscaling policy"
  default     = 4
  validation {
    condition     = var.max_replicas >= 1 && var.max_replicas <= 10
    error_message = "Input max_replicas must be a whole number between 1 and 10."
  }
}

variable "min_replicas" {
  type        = number
  description = "The minimum number of replicas for the autoscaling policy"
  default     = 1
}

variable "cooldown_period" {
  type        = number
  description = "The number of seconds that the autoscaler should wait before it starts collecting information from a new instance. This prevents the autoscaler from collecting information when the instance is initializing, during which the collected usage would not be reliable"
  default     = 900
}

variable "target_cpu_util_value" {
  type        = number
  description = "The target custom CPU utilization value for the autoscaling policy"
  default     = 80
}


# Cloud Function Module specific variables
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

variable "storage_bucket_location" {
  type        = string
  description = "*Optional if var.byo_storage_bucket is true*. Location for the Storage Bucket. Must be a multi-region or dual-region location. See https://cloud.google.com/storage/docs/locations for more details"
  default     = "US"
}

variable "storage_bucket_name" {
  type        = string
  description = "Name of either the existing Storage Bucket name if var.byo_storage_bucket is true, or the new Storage Bucket name if var.byo_storage_bucket is false."
  default     = ""
}

variable "cloud_function_source_object_path" {
  type        = string
  description = "By default, this Terraform module will download the latest version of the Cloud Run Function ZIP and save it to the root/function_zip directory. If upload_cloud_function_ip is set to true, this variable path will be used as the source to upload the zip file to the specified Storage Bucket"
  default     = "./function_zip/cloud-functions-latest.zip"
}

variable "cloud_function_source_object_name" {
  type        = string
  description = "Name of existing Storage Bucket Object (zip file) name. Defaults to zscaler_cc_cloud_run_function.zip. Only change if you have renamed the file/path for an existing storage bucket"
  default     = "zscaler_cc_cloud_run_function.zip"
}


# Cloud Function Environment Variable Configuration
variable "sync_dry_run" {
  description = "Whether to run sync in dry-run mode"
  type        = bool
  default     = false
}

variable "sync_max_deletions_per_run" {
  description = "Maximum Cloud Connector VMs that can be deleted per sync run"
  type        = number
  default     = 16
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
  default     = 15
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
  default     = 5
}

variable "zscaler_user_agent" {
  description = "Custom User-Agent for Zscaler API requests"
  type        = string
  default     = "GCP-HealthMonitor/1.0 (Function: resource-sync)"
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

variable "upload_cloud_function_zip" {
  type        = bool
  description = "By default, this Terraform module will create a new Storage Bucket and upload the zip file to it. Setting this value to false will prevent creation/upload of the bucket object"
  default     = true
}
