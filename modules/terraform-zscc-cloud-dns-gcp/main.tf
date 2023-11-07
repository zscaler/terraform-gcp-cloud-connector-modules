################################################################################
# Create Cloud DNS Forwarding Zones for ZPA domains
################################################################################
resource "google_dns_managed_zone" "dns_forward_zone" {
  for_each = var.domain_names
  name     = "${var.name_prefix}-fwd-rule-${each.key}-${var.resource_tag}"
  project  = var.project
  dns_name = each.value


  visibility = "private"

  private_visibility_config {
    dynamic "networks" {
      for_each = var.vpc_networks
      content {
        network_url = networks.value
      }
    }
  }

  forwarding_config {
    dynamic "target_name_servers" {
      for_each = var.target_address

      content {
        ipv4_address    = target_name_servers.value
        forwarding_path = "private"
      }
    }
  }
}


################################################################################
# Allow GCP Cloud DNS service IP ranges to query the Cloud Connector service
# VPC network
################################################################################
resource "google_compute_firewall" "allow_cloud_dns" {
  count   = length(var.vpc_networks)
  name    = "${var.name_prefix}-permit-cloud-dns-vpc-${count.index}-${var.resource_tag}"
  project = coalesce(var.project_host, var.project)
  #create resource in same "host" project as VPC Network assuming this is different than the "service" project where ILB resources will be created 

  network = element(var.vpc_networks, count.index)
  allow {
    protocol = "tcp"
    ports    = ["53"]
  }
  allow {
    protocol = "udp"
    ports    = ["53"]
  }
  source_ranges = ["35.199.192.0/19"]
}
