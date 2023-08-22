################################################################################
# Create a Google internal LB
################################################################################
resource "google_compute_health_check" "cc_health_check" {
  name    = "${var.name_prefix}-cc-health-check-${var.resource_tag}"
  project = var.project

  timeout_sec         = 5
  check_interval_sec  = var.health_check_interval
  healthy_threshold   = var.healthy_threshold
  unhealthy_threshold = var.unhealthy_threshold
  http_health_check {
    port         = var.http_probe_port
    request_path = "/?cchealth"
  }
}


resource "google_compute_region_backend_service" "backend_service" {
  name    = "${var.name_prefix}-udp-backend-service-${var.resource_tag}"
  project = var.project

  health_checks         = [google_compute_health_check.cc_health_check.self_link]
  load_balancing_scheme = "INTERNAL"
  session_affinity      = var.session_affinity
  network               = var.vpc_network
  protocol              = "UDP"

  dynamic "backend" {
    for_each = var.instance_groups

    content {
      group = backend.value
    }
  }
}


################################################################################
# Create a Front End IP Address for ILB (if enabled)
################################################################################
resource "google_compute_address" "ilb_ip_address" {
  name         = "${var.name_prefix}-ilb-ip-address-${var.resource_tag}"
  region       = var.region
  subnetwork   = var.vpc_subnetwork_ccvm_service
  address_type = "INTERNAL"
}


resource "google_compute_forwarding_rule" "ilb_forwarding" {
  name    = "${var.name_prefix}-forwarding-rule-${var.resource_tag}"
  project = var.project
  region  = var.region

  ip_address            = google_compute_address.ilb_ip_address.address
  ip_protocol           = "UDP"
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.backend_service.id
  all_ports             = true
  network               = var.vpc_network
  subnetwork            = var.vpc_subnetwork_ccvm_service
  allow_global_access   = var.allow_global_access
}


resource "google_compute_firewall" "allow_cc_health_check" {
  name    = "${var.name_prefix}-allow-cc-health-check-${var.resource_tag}"
  project = var.project

  network   = var.vpc_network
  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = google_compute_health_check.cc_health_check.tcp_health_check[*].port
  }
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
}
