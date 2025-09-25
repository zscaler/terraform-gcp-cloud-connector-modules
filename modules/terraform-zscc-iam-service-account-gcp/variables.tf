variable "secret_name" {
  type        = string
  description = "GCP Secret Manager friendly name. Not required if using byo_service_account_id or HashiCorp Vault"
  default     = ""
}

variable "project" {
  type        = string
  description = "Google Cloud project name"
}

variable "service_account_id" {
  type        = string
  description = "Custom Service Account ID string for Cloud Connector"
  default     = ""
}

variable "service_account_display_name" {
  type        = string
  description = "Custom Service Account display name string for Cloud Connector"
  default     = ""
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

  validation {
    condition     = var.byo_ccvm_service_account == "" || can(regex("@", var.byo_ccvm_service_account))
    error_message = "The variable 'byo_ccvm_service_account' must be a full service account email address."
  }
}

variable "hcp_vault_enabled" {
  type        = bool
  description = "Enable a specific outbound firewall rule for Cloud Connector to be able to establish connectivity to customer provided HCP Vault address. Default is false"
  default     = false
}


variable "grant_pubsub_editor" {
  type        = bool
  default     = false
  description = "If true, grant roles/pubsub.editor to the CCVM SA at project scope"
}
