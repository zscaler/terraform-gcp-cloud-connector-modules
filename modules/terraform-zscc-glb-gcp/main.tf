################################################################################
# Create a Google internal LB
################################################################################
resource "google_compute_region_health_check" "glb_cc_health_check" {
  name    = var.glb_health_check_name
  project = var.project
  region  = var.region

  timeout_sec         = 5
  check_interval_sec  = var.health_check_interval
  healthy_threshold   = var.healthy_threshold
  unhealthy_threshold = var.unhealthy_threshold
  http_health_check {
    port         = var.http_probe_port
    request_path = "/?cchealth"
  }
}


resource "google_compute_region_backend_service" "glb-backend_service" {
  name    = var.glb_backend_service_name
  project = var.project

  health_checks         = [google_compute_region_health_check.glb_cc_health_check.self_link]
  load_balancing_scheme = "EXTERNAL"
  session_affinity      = var.session_affinity
  protocol              = "TCP"

  dynamic "backend" {
    for_each = var.instance_groups

    content {
      group          = backend.value
      balancing_mode = "CONNECTION"
    }
  }
}


################################################################################
# Create a Front End IP Address for GLB
################################################################################
resource "google_compute_address" "glb_ip_address" {
  name         = var.glb_frontend_ip_name
  region       = var.region
  address_type = "EXTERNAL"
  project      = var.project
}


resource "google_compute_forwarding_rule" "glb_forwarding" {
  name    = var.glb_forwarding_rule_name
  project = var.project
  region  = var.region

  ip_address            = google_compute_address.glb_ip_address.address
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  backend_service       = google_compute_region_backend_service.glb-backend_service.id
  ports                 = ["80", "443"]
  allow_global_access   = var.allow_global_access
}


resource "google_compute_firewall" "glb_allow_cc_health_check" {
  name    = var.fw_glb_health_check_name
  project = coalesce(var.project_host, var.project)
  #create resource in same "host" project as VPC Network assuming this is different than the "service" project where GLB resources will be created 

  network   = var.vpc_network
  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = [var.http_probe_port]
  }
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["allow-health-checks"]
}
