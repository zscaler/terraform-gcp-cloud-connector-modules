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

variable "region" {
  type        = string
  description = "Google Cloud region"
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
  default     = "zs-image-gcp-20230928152536-la-1"
}

variable "domain_names" {
  type        = map(any)
  description = "Domain names fqdn/wildcard to have Google Cloud DNS zone forward ZPA App Segment DNS requests to Cloud Connector"
  default     = {}
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

variable "zpa_enabled" {
  type        = bool
  description = "Configure Cloud DNS for ZPA zone forwarding"
  default     = false
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

# BYO (Bring-your-own) variables list

variable "byo_vpc" {
  type        = bool
  description = "Bring your own GCP VPC for Cloud Connector"
  default     = false
}

variable "byo_mgmt_vpc_name" {
  type        = string
  description = "User provided existing GCP VPC friendly name for Management interface"
  default     = null
}

variable "byo_service_vpc_name" {
  type        = string
  description = "User provided existing GCP VPC friendly name for Forwarding/Service interfaces"
  default     = null
}

variable "byo_subnets" {
  type        = bool
  description = "Bring your own GCP Subnets for Cloud Connector"
  default     = false
}

variable "byo_mgmt_subnet_name" {
  type        = string
  description = "User provided existing GCP Subnet friendly name for Management VPC"
  default     = null
}

variable "byo_service_subnet_name" {
  type        = string
  description = "User provided existing GCP Subnet friendly name for Forwarding/Service VPC"
  default     = null
}

variable "byo_router" {
  type        = bool
  description = "Bring your own GCP Compute Router for Cloud Connector"
  default     = false
}

variable "byo_mgmt_router_name" {
  type        = string
  description = "User provided existing GCP Compute Router friendly name for Management VPC"
  default     = null
}

variable "byo_service_router_name" {
  type        = string
  description = "User provided existing GCP Compute Router friendly name for Forwarding/Service VPC"
  default     = null
}

variable "byo_natgw" {
  type        = bool
  description = "Bring your own GCP NAT Gateway Cloud Connector"
  default     = false
}

variable "byo_mgmt_natgw_name" {
  type        = string
  description = "User provided existing GCP NAT Gateway friendly name for Management VPC"
  default     = null
}

variable "byo_service_natgw_name" {
  type        = string
  description = "User provided existing GCP NAT Gateway friendly name for Forwarding/Service VPC"
  default     = null
}
