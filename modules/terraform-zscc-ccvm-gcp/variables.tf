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

variable "user_data" {
  type        = string
  description = "Cloud Init data"
}

variable "project" {
  type        = string
  description = "Google Cloud project name"
}

variable "region" {
  type        = string
  description = "Google Cloud region"
}

variable "zones" {
  type        = list(string)
  description = "Availability zone names"
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

variable "ssh_key" {
  type        = string
  description = "A public key uploaded to the Cloud Connector instances"
}

variable "cc_count" {
  type        = number
  description = "Default number of Cloud Connector appliances to create"
  default     = 1
}

variable "vpc_subnetwork_ccvm_mgmt" {
  type        = string
  description = "VPC subnetwork for CC VM MGMT"
}

variable "vpc_subnetwork_ccvm_service" {
  type        = string
  description = "VPC subnetwork for CC VM service"
}

variable "image_name" {
  type        = string
  description = "Custom image name to be used for deploying Cloud Connector appliances. Ideally all VMs should be on the same Image as templates always pull the latest from Google Marketplace. This variable is provided if a customer desires to override/retain an old ami for existing deployments rather than upgrading and forcing a replacement. It is also inputted as a list to facilitate if a customer desired to manually upgrade select CCs deployed based on the cc_count index"
  default     = ""
}

variable "service_account" {
  type        = string
  description = "IAM Service Account Email to be assigned to each Cloud Connector instance"
}

variable "update_policy_type" {
  type        = string
  description = "The type of update process. You can specify either PROACTIVE so that the instance group manager proactively executes actions in order to bring instances to their target versions or OPPORTUNISTIC so that no action is proactively executed but the update will be performed as part of other actions (for example, resizes or recreateInstances calls)"
  default     = "OPPORTUNISTIC"
  validation {
    condition = (
      var.update_policy_type == "PROACTIVE" ||
      var.update_policy_type == "OPPORTUNISTIC"
    )
    error_message = "Input update_policy_type must be set to an approved value."
  }
}

variable "update_policy_replacement_method" {
  type        = string
  description = "The instance replacement method for managed instance groups. Valid values are: RECREATE or SUBSTITUTE. If SUBSTITUTE, the group replaces VM instances with new instances that have randomly generated names. If RECREATE, instance names are preserved. You must also set max_unavailable_fixed or max_unavailable_percent to be greater than 0"
  default     = "RECREATE"
  validation {
    condition = (
      var.update_policy_replacement_method == "RECREATE" ||
      var.update_policy_replacement_method == "SUBSTITUTE"
    )
    error_message = "Input update_policy_replacement_method must be set to an approved value."
  }
}

variable "update_policy_max_surge_fixed" {
  type        = number
  description = "The maximum number of instances that can be created above the specified targetSize during the update process. Conflicts with max_surge_percent. If neither is set, defaults to 1"
  default     = 0
}

variable "update_max_unavailable_fixed" {
  type        = number
  description = "The maximum number of instances that can be unavailable during the update process. Conflicts with max_unavailable_percent. If neither is set, defaults to 1"
  default     = 1
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
  description = " The name of the Instance Group Manager. Must be 1-63 characters long and comply with RFC1035. Supported characters include lowercase letters, numbers, and hyphens"
  default     = [""]
}

variable "base_instance_name" {
  type        = list(string)
  description = "The base instance name to use for instances in this group. The value must be a valid RFC1035 name. Supported characters are lowercase letters, numbers, and hyphens (-). Instances are named by appending a hyphen and a random four-character string to the base instance name"
  default     = [""]
}

variable "stateful_delete_rule" {
  type        = string
  description = " A value that prescribes what should happen to the stateful disk when the VM instance is deleted. The available options are NEVER and ON_PERMANENT_INSTANCE_DELETION. NEVER - detach the disk when the VM is deleted, but do not delete the disk. ON_PERMANENT_INSTANCE_DELETION will delete the stateful disk when the VM is permanently deleted from the instance group."
  default     = "ON_PERMANENT_INSTANCE_DELETION"
}

variable "tags" {
  type        = list(string)
  description = "Tags used to modify routes applied to the instances"
  default     = []
}
