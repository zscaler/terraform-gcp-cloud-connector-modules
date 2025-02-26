################################################################################
# Create Cloud Connector Instance Template
################################################################################
resource "google_compute_instance_template" "cc_instance_template" {
  name_prefix    = var.instance_template_name == "" ? coalesce(var.instance_template_name_prefix, "${var.name_prefix}-cc-template-${var.resource_tag}-") : null
  name           = var.instance_template_name != "" ? var.instance_template_name : null
  project        = var.project
  region         = var.region
  tags           = var.tags
  machine_type   = var.ccvm_instance_type
  can_ip_forward = true

  disk {
    source_image = var.image_name
    auto_delete  = true
    boot         = true
    disk_type    = "pd-balanced"
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  network_interface {
    subnetwork = var.vpc_subnetwork_ccvm_service
  }

  network_interface {
    subnetwork = var.vpc_subnetwork_ccvm_mgmt
  }

  metadata = {
    ssh-keys                = "zsroot:${var.ssh_key}"
    ZSCALER                 = var.user_data
    enable-guest-attributes = "TRUE"
  }

  service_account {
    email  = var.service_account
    scopes = ["cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
  }
}


################################################################################
# Create Zonal Managed Instance Groups per number of zones defined
# Create X number of Cloud Connectors in each group per cc_count variable
################################################################################
resource "google_compute_instance_group_manager" "cc_instance_group_manager" {
  count   = length(var.zones)
  name    = coalesce(element(var.instance_group_name, count.index), "${var.name_prefix}-cc-mig-az-${count.index + 1}-${var.resource_tag}")
  project = var.project
  zone    = element(var.zones, count.index)

  base_instance_name = coalesce(element(var.base_instance_name, count.index), "${var.name_prefix}-mig-az-${count.index + 1}-ccvm-${var.resource_tag}")
  version {
    instance_template = google_compute_instance_template.cc_instance_template.id
  }
  target_size = var.cc_count

  update_policy {
    type                           = var.update_policy_type
    minimal_action                 = "REPLACE"
    most_disruptive_allowed_action = "REPLACE"
    max_surge_fixed                = var.update_policy_max_surge_fixed
    max_unavailable_fixed          = var.update_max_unavailable_fixed
    replacement_method             = var.update_policy_replacement_method
  }

  stateful_disk {
    device_name = google_compute_instance_template.cc_instance_template.disk[0].device_name
    delete_rule = var.stateful_delete_rule
  }

  stateful_internal_ip {
    interface_name = google_compute_instance_template.cc_instance_template.network_interface[0].name
    delete_rule    = var.stateful_delete_rule
  }

  stateful_internal_ip {
    interface_name = google_compute_instance_template.cc_instance_template.network_interface[1].name
    delete_rule    = var.stateful_delete_rule
  }

  lifecycle {
    create_before_destroy = true
  }
}


################################################################################
# Wait for Instance Group creation to collect individual compute details
################################################################################
resource "time_sleep" "wait_60_seconds" {
  depends_on      = [google_compute_instance_group_manager.cc_instance_group_manager]
  create_duration = "60s"
}

data "google_compute_instance_group" "cc_instance_groups" {
  count     = length(google_compute_instance_group_manager.cc_instance_group_manager[*].instance_group)
  self_link = element(google_compute_instance_group_manager.cc_instance_group_manager[*].instance_group, count.index)

  depends_on = [
    time_sleep.wait_60_seconds
  ]
}

data "google_compute_instance" "cc_vm_instances" {
  count     = var.cc_count * length(var.zones)
  self_link = element(tolist(flatten([for instances in data.google_compute_instance_group.cc_instance_groups[*].instances : instances])), count.index)
}
