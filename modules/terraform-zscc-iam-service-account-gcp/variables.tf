variable "secret_name" {
  type        = string
  description = "GCP Secret Manager friendly name"
}

variable "project" {
  type        = string
  description = "Google Cloud project name"
}

variable "service_account_id" {
  type        = string
  description = "Custom Service Account ID string for Cloud Connector"
}

variable "service_account_display_name" {
  type        = string
  description = "Custom Service Account display name string for Cloud Connector"
}
