variable "name_prefix" {
  type        = string
  description = "A prefix to associate to all the module resources"
  default     = null
}

variable "resource_tag" {
  type        = string
  description = "A random string for the resource name"
}

variable "project" {
  type        = string
  description = "Google Cloud project name"
}

variable "region" {
  type        = string
  description = "Google Cloud region"
}

variable "subnet_bastion" {
  type        = string
  description = "A subnet IP CIDR for the greenfield/test bastion host in the Management VPC. This value will be ignored if bastion_enabled variable is set to false"
  default     = "10.0.0.0/24"
}

variable "subnet_workload" {
  type        = string
  description = "A subnet IP CIDR for the greenfield/test workload in the Service VPC. This value will be ignored if workloads_enabled variable is set to false"
  default     = "10.1.2.0/24"
}

variable "subnet_cc_mgmt" {
  type        = string
  description = "A subnet IP CIDR for the Cloud Connector in the Management VPC. This value will be ignored if byo_mgmt_subnet_name is set to true"
  default     = "10.0.1.0/24"
}

variable "subnet_cc_service" {
  type        = string
  description = "A subnet IP CIDR for the Cloud Connector/Load Balancer in the Service VPC. This value will be ignored if byo_service_subnet_name is set to true"
  default     = "10.1.1.0/24"
}

variable "allowed_ssh_from_internal_cidr" {
  type        = list(string)
  description = "CIDR allowed to ssh the Cloud Connector from Intranet. Defaults to RFC1918 in not specified"
  default     = ["10.0.0.0/8", "192.168.0.0/16", "172.16.0.0/12"]
}

variable "allowed_ports" {
  type        = list(string)
  description = "A list of ports to permit inbound to Cloud Connector Service VPC. Default empty list means to allow all."
  default     = []
}

variable "default_nsg" {
  type        = list(string)
  description = "Default CIDR list to permit workload traffic destined for Cloud Connector"
  default     = ["0.0.0.0/0"]
}

variable "workloads_enabled" {
  type        = bool
  default     = false
  description = "Configure Workload subnet in Service VPC with accompanying bastion host for SSH access to test client workloads if set to true"
}

variable "bastion_enabled" {
  type        = bool
  default     = false
  description = "Configure bastion subnet in Management VPC for SSH access to Cloud Connector if set to true"
}

variable "routing_mode" {
  type        = string
  default     = "REGIONAL"
  description = "The network-wide routing mode to use. If set to REGIONAL, this network's cloud routers will only advertise routes with subnetworks of this network in the same region as the router. If set to GLOBAL, this network's cloud routers will advertise routes with all subnetworks of this network, across regions. Possible values are: REGIONAL, GLOBAL"
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

variable "support_access_enabled" {
  type        = bool
  description = "Enable a specific outbound firewall rule for Cloud Connector to be able to establish connectivity for Zscaler support access. Default is true"
  default     = true
}

variable "hcp_vault_enabled" {
  type        = bool
  description = "Enable a specific outbound firewall rule for Cloud Connector to be able to establish connectivity to customer provided HCP Vault address. Default is false"
  default     = false
}

variable "fw_cc_mgmt_hcp_vault_address_name" {
  type        = string
  description = "The name of the compute firewall created on the user defined Cloud Connector Management VPC Network permitting CC to access to HCP Vault Address port number"
  default     = null
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
