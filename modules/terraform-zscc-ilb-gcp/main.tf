################################################################################
# Create a Google internal LB
################################################################################
resource "google_compute_health_check" "cc_health_check" {
  name    = var.ilb_health_check_name
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
  name    = var.ilb_backend_service_name
  project = var.project

  health_checks         = [google_compute_health_check.cc_health_check.self_link]
  load_balancing_scheme = "INTERNAL"
  session_affinity      = var.session_affinity
  network               = var.vpc_network
  protocol              = "UDP"

  dynamic "backend" {
    for_each = var.instance_groups

    content {
      group          = backend.value
      balancing_mode = "CONNECTION"
    }
  }
}


################################################################################
# Create a Front End IP Address for ILB
################################################################################
resource "google_compute_address" "ilb_ip_address" {
  name         = var.ilb_frontend_ip_name
  region       = var.region
  subnetwork   = var.vpc_subnetwork_ccvm_service
  address_type = "INTERNAL"
  project      = var.project
}


resource "google_compute_forwarding_rule" "ilb_forwarding" {
  name    = var.ilb_forwarding_rule_name
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
  name    = var.fw_ilb_health_check_name
  project = coalesce(var.project_host, var.project)
  #create resource in same "host" project as VPC Network assuming this is different than the "service" project where ILB resources will be created 

  network   = var.vpc_network
  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = google_compute_health_check.cc_health_check.tcp_health_check[*].port
  }
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
}
