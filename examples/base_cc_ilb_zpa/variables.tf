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
  description = "A list of ports to permit inbound to Cloud Connector Service VPC. Default empty list means to allow all."
  default     = []
  type        = list(string)
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
  description = "Google Cloud Secret Name in Secret Manager"
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

variable "cc_count" {
  type        = number
  description = "Default number of Cloud Connector appliances to create per Instance Group/Availability Zone"
  default     = 2
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

variable "domain_names" {
  type        = map(any)
  description = "Domain names fqdn/wildcard to have Google Cloud DNS zone forward ZPA App Segment DNS requests to Cloud Connector"
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
  description = "Creates a unique Instance Template name beginning with the specified prefix"
  default     = null
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
