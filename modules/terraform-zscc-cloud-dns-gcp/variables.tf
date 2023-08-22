variable "name_prefix" {
  type        = string
  description = "A prefix to associate to all the bastion module resources"
  default     = null
}

variable "resource_tag" {
  type        = string
  description = "A random string for the resource name"
}

variable "target_address" {
  type        = list(string)
  description = "Google Cloud DNS queries will be conditionally forwarded to these target IP addresses. Default is the Cloud Connector ILB frontend IP (or service IP for standalone)"
}

variable "domain_names" {
  type        = map(any)
  description = "Domain names fqdn/wildcard to have Google Cloud DNS zone forward ZPA App Segment DNS requests to Cloud Connector"
}

variable "vpc_networks" {
  type        = list(string)
  description = "VPC Networks to bind DNS Zone forwarding to"
}
