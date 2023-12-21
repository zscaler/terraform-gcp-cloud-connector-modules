################################################################################
# Create Service Account to be assigned to Workload client
################################################################################
resource "google_service_account" "service_account_workload" {
  account_id   = "${var.name_prefix}-wkld-sa-${var.resource_tag}"
  display_name = "${var.name_prefix}-wkld-sa-${var.resource_tag}"
}


################################################################################
# Create workload instance host with automatic public IP association
################################################################################
resource "google_compute_instance" "server_host" {
  count        = var.workload_count
  name         = "${var.name_prefix}-workload-${count.index + 1}-${var.resource_tag}"
  machine_type = var.instance_type
  zone         = element(var.zones, count.index)
  tags         = ["zscc-workload"]
  network_interface {
    subnetwork = var.subnet
  }
  metadata = {
    ssh-keys = "ubuntu:${var.ssh_key}"
  }
  metadata_startup_script = "sudo apt install net-tools"
  boot_disk {
    initialize_params {
      image = var.workload_image_name
      type  = "pd-ssd"
      size  = "10"
    }
  }
  service_account {
    email  = google_service_account.service_account_workload.email
    scopes = ["cloud-platform"]
  }
}

################################################################################
# Create pre-defined GCP Firewall rules for Workload
################################################################################
resource "google_compute_firewall" "ssh_intranet_workload" {
  name    = "${var.name_prefix}-fw-ssh-for-workload-${var.resource_tag}"
  network = var.vpc_network
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges           = var.allowed_ssh_from_internal_cidr
  target_service_accounts = [google_service_account.service_account_workload.email]
}
