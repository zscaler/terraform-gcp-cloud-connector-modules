variable "name_prefix" {
  type        = string
  description = "A prefix to associate to all the bastion module resources"
  default     = null
}

variable "resource_tag" {
  type        = string
  description = "A tag to associate to all bastion module resources"
  default     = null
}

variable "public_subnet" {
  type        = string
  description = "The public subnet where the bastion host has to be attached"
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

variable "zone" {
  type        = string
  description = "The zone that the machine should be created in. If it is not provided, the provider zone is used"
  default     = null
}

variable "workload_image_name" {
  type        = string
  description = "Custom image name to be used for deploying bastion/workload appliances"
  default     = "ubuntu-os-cloud/ubuntu-2204-lts"
}

variable "bastion_ssh_allow_ip" {
  type        = list(string)
  description = "CIDR blocks of trusted networks for bastion host ssh access from Internet"
  default     = ["0.0.0.0/0"]
}

variable "vpc_network" {
  type        = string
  description = "Bastion VPC network"
}
