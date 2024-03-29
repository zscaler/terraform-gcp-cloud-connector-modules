variable "name_prefix" {
  type        = string
  description = "A prefix to associate to all the workload module resources"
  default     = null
}

variable "resource_tag" {
  type        = string
  description = "A tag to associate to all workload module resources"
  default     = null
}

variable "subnet" {
  type        = string
  description = "A subnet the workload host is in"
}

variable "instance_type" {
  type        = string
  description = "The bastion host instance type"
  default     = "e2-micro"
}

variable "ssh_key" {
  type        = string
  description = "A public key uploaded to the bastion instance"
}

variable "zones" {
  type        = list(string)
  description = "The zone that the machine should be created in. If it is not provided, the provider zone is used"
}

variable "allowed_ssh_from_internal_cidr" {
  type        = list(string)
  description = "CIDR allowed to ssh the bastion host from Intranet"
}

variable "workload_image_name" {
  type        = string
  description = "Custom image name to be used for deploying bastion/workload appliances"
  default     = "ubuntu-os-cloud/ubuntu-2204-lts"
}

variable "vpc_network" {
  type        = string
  description = "Workload VPC network"
}

variable "workload_count" {
  type        = number
  description = "The number of Workload VMs to deploy"
  default     = 1
  validation {
    condition     = var.workload_count >= 1 && var.workload_count <= 250
    error_message = "Input workload_count must be a whole number between 1 and 250."
  }
}
