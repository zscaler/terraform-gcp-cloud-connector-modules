################################################################################
# Create Service Account to be assigned to bastion workload
################################################################################
resource "google_service_account" "service_account_bastion" {
  account_id   = "${var.name_prefix}-jump-sa-${var.resource_tag}"
  display_name = "${var.name_prefix}-jump-sa-${var.resource_tag}"
}

################################################################################
# Create Bastion instance host with automatic public IP association
################################################################################
resource "google_compute_instance" "bastion" {
  name         = "${var.name_prefix}-bastion-host-${var.resource_tag}"
  machine_type = var.instance_type
  zone         = var.zone
  network_interface {
    subnetwork = var.public_subnet
    access_config {
      #Ephemeral IP
    }
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
    email  = google_service_account.service_account_bastion.email
    scopes = ["cloud-platform"]
  }
}


################################################################################
# Create pre-defined GCP Firewall rules for Bastion
################################################################################
resource "google_compute_firewall" "ssh_internet_ingress" {
  name        = "${var.name_prefix}-fw-ssh-for-internet-${var.resource_tag}"
  description = "Permit SSH Access to bastion host from Internet for approved source IP ranges"
  network     = var.vpc_network
  direction   = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges           = var.bastion_ssh_allow_ip
  target_service_accounts = [google_service_account.service_account_bastion.email]
}
