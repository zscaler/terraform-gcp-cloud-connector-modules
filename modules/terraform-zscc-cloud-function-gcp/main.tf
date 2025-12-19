
################################################################################
# Create Cloud Function Dependencies
################################################################################
# Create Storage Bucket to store Cloud Function
resource "google_storage_bucket" "cc_storage_bucket" {
  count                       = var.byo_storage_bucket ? 0 : 1
  name                        = var.storage_bucket_name # Every bucket name must be globally unique
  location                    = var.storage_bucket_location
  uniform_bucket_level_access = var.uniform_bucket_level_access
}

# Or use an existing storage bucket
data "google_storage_bucket" "existing_storage_bucket" {
  count = var.byo_storage_bucket ? 1 : 0
  name  = var.storage_bucket_name
}

# Upload Cloud Function zip file to newly created or existing Storage Bucket
resource "google_storage_bucket_object" "upload_cloud_function_zip_object" {
  count          = var.upload_cloud_function_zip ? 1 : 0
  name           = var.cloud_function_source_object_name
  bucket         = try(data.google_storage_bucket.existing_storage_bucket[0].name, google_storage_bucket.cc_storage_bucket[0].name)
  source         = var.cloud_function_source_object_path
  content_type   = "application/zip"
  detect_md5hash = filemd5(var.cloud_function_source_object_path)
}

# Or reference an existing storage object (implying that both the bucket AND object zip file exists already)
data "google_storage_bucket_object" "existing_cloud_function_zip_object" {
  count  = var.upload_cloud_function_zip ? 0 : 1
  name   = var.cloud_function_source_object_name
  bucket = try(data.google_storage_bucket.existing_storage_bucket[0].name, google_storage_bucket.cc_storage_bucket[0].name)
}


################################################################################
# Create Service Account to be assigned to Cloud Run Function
################################################################################
resource "google_service_account" "service_account_function" {
  count        = var.byo_function_service_account != "" ? 0 : 1
  account_id   = var.cloud_function_service_account_id
  display_name = var.cloud_function_service_account_display_name
  project      = var.project
}

# Or use existing Service Account
data "google_service_account" "service_account_function_selected" {
  count      = var.byo_function_service_account != "" ? 1 : 0
  account_id = var.byo_function_service_account
}


# Cloud Run Function Service Account Permissions
################################################################################
# Assign Service Account the Compute Instance Admin (v1) role
################################################################################
resource "google_project_iam_member" "cloud_function_instance_admin" {
  count   = var.byo_function_service_account != "" ? 0 : 1
  project = var.project
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${var.byo_function_service_account != "" ? data.google_service_account.service_account_function_selected[0].email : google_service_account.service_account_function[0].email}"
}

################################################################################
# Assign Service Account the Monitoring Viewer role
################################################################################
resource "google_project_iam_member" "cloud_function_monitoring_viewer" {
  count   = var.byo_function_service_account != "" ? 0 : 1
  project = var.project
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${var.byo_function_service_account != "" ? data.google_service_account.service_account_function_selected[0].email : google_service_account.service_account_function[0].email}"
}

################################################################################
# Assign Service Account the Logging Writer role
################################################################################
resource "google_project_iam_member" "cloud_function_logging_writer" {
  count   = var.byo_function_service_account != "" ? 0 : 1
  project = var.project
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${var.byo_function_service_account != "" ? data.google_service_account.service_account_function_selected[0].email : google_service_account.service_account_function[0].email}"
}

################################################################################
# Assign Service Account the Cloud Run Invoker role
################################################################################
resource "google_project_iam_member" "cloud_run_invoker" {
  count   = var.byo_function_service_account != "" ? 0 : 1
  project = var.project
  role    = "roles/run.invoker"
  member  = "serviceAccount:${var.byo_function_service_account != "" ? data.google_service_account.service_account_function_selected[0].email : google_service_account.service_account_function[0].email}"
}

################################################################################
# Assign Service Account access to provided Secret Manager resource
################################################################################
### If var.secret_name is populated AND not bringing an existing SA, then create SA and assign it Secret Accessor role to that Secret ID
resource "google_secret_manager_secret_iam_member" "cloud_run_secrets_accessor" {
  count     = var.byo_function_service_account != "" ? 0 : 1
  secret_id = var.secret_name
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.byo_function_service_account != "" ? data.google_service_account.service_account_function_selected[0].email : google_service_account.service_account_function[0].email}"
  project   = var.project

  lifecycle {
    ignore_changes = [
      project #ignore unnecessary changes if secret manager is in a different project than the parent account for this resource
    ]
  }
}

# builder permissions need to stablize before it can pull the source zip
resource "time_sleep" "wait_60s" {
  create_duration = "60s"

  depends_on = [
    google_project_iam_member.cloud_function_instance_admin,
    google_project_iam_member.cloud_function_monitoring_viewer,
    google_project_iam_member.cloud_function_logging_writer,
    google_project_iam_member.cloud_run_invoker,
  ]
}


# Create Cloud Function for Health Monitoring
resource "google_cloudfunctions2_function" "health_monitor_function" {
  name        = "${var.name_prefix}-cc-health-monitor-${var.resource_tag}-function"
  location    = var.region
  description = "Zscaler Cloud Run Function for Cloud Connector Autoscaling, Health Monitoring, and auto cleanup operations"

  build_config {
    runtime     = var.runtime
    entry_point = "health_monitor_entry"
    source {
      storage_source {
        bucket = try(data.google_storage_bucket.existing_storage_bucket[0].name, google_storage_bucket.cc_storage_bucket[0].name)
        object = try(data.google_storage_bucket_object.existing_cloud_function_zip_object[0].name, google_storage_bucket_object.upload_cloud_function_zip_object[0].name)
      }
    }
  }

  service_config {
    max_instance_count    = 10
    available_memory      = "512M"
    timeout_seconds       = 540
    service_account_email = var.byo_function_service_account != "" ? data.google_service_account.service_account_function_selected[0].email : google_service_account.service_account_function[0].email
    environment_variables = {
      PROJECT_ID                                = var.project
      REGION                                    = var.region
      INSTANCE_GROUPS                           = jsonencode(var.instance_group_names)
      SECRET_NAME                               = var.secret_name
      ZSCALER_BASE_URL                          = var.cc_vm_prov_url
      SYNC_DRY_RUN                              = tostring(var.sync_dry_run)
      SYNC_MAX_DELETIONS_PER_RUN                = tostring(var.sync_max_deletions_per_run)
      SYNC_EXCLUDED_INSTANCES                   = jsonencode(var.sync_excluded_instances)
      MISSING_METRICS_WARNING_THRESHOLD_MIN     = tostring(var.missing_metrics_warning_threshold_min)
      MISSING_METRICS_CRITICAL_THRESHOLD_MIN    = tostring(var.missing_metrics_critical_threshold_min)
      MISSING_METRICS_TERMINATION_THRESHOLD_MIN = tostring(var.missing_metrics_termination_threshold_min)
      UNHEALTHY_METRIC_THRESHOLD                = tostring(var.unhealthy_metric_threshold)
      CONSECUTIVE_UNHEALTHY_THRESHOLD           = tostring(var.consecutive_unhealthy_threshold)
      ZSCALER_USER_AGENT                        = var.zscaler_user_agent
    }
  }

  labels = {
    component = "health-monitor"
  }
}


# Create Cloud Function for Resource Sync
resource "google_cloudfunctions2_function" "resource_sync_function" {
  name        = "${var.name_prefix}-cc-resource-sync-${var.resource_tag}-function"
  location    = var.region
  description = "Performs synchronization and reconciliation instance resources between GCP and Zscaler"

  build_config {
    runtime     = "python312"
    entry_point = "resource_sync_entry"
    source {
      storage_source {
        bucket = try(data.google_storage_bucket.existing_storage_bucket[0].name, google_storage_bucket.cc_storage_bucket[0].name)
        object = try(data.google_storage_bucket_object.existing_cloud_function_zip_object[0].name, google_storage_bucket_object.upload_cloud_function_zip_object[0].name)
      }
    }
  }

  service_config {
    max_instance_count    = 10
    available_memory      = "512M"
    timeout_seconds       = 540
    service_account_email = var.byo_function_service_account != "" ? data.google_service_account.service_account_function_selected[0].email : google_service_account.service_account_function[0].email
    environment_variables = {
      PROJECT_ID                                = var.project
      REGION                                    = var.region
      INSTANCE_GROUPS                           = jsonencode(var.instance_group_names)
      SECRET_NAME                               = var.secret_name
      ZSCALER_BASE_URL                          = var.cc_vm_prov_url
      SYNC_DRY_RUN                              = tostring(var.sync_dry_run)
      SYNC_MAX_DELETIONS_PER_RUN                = tostring(var.sync_max_deletions_per_run)
      SYNC_EXCLUDED_INSTANCES                   = jsonencode(var.sync_excluded_instances)
      MISSING_METRICS_WARNING_THRESHOLD_MIN     = tostring(var.missing_metrics_warning_threshold_min)     # consecutive missing datapoints to warn
      MISSING_METRICS_CRITICAL_THRESHOLD_MIN    = tostring(var.missing_metrics_critical_threshold_min)    # consecutive missing datapoints to alarm
      MISSING_METRICS_TERMINATION_THRESHOLD_MIN = tostring(var.missing_metrics_termination_threshold_min) # consecutive missing datapoints to terminate
      UNHEALTHY_METRIC_THRESHOLD                = tostring(var.unhealthy_metric_threshold)                # total unhealthy datapoints threshold within eval period
      CONSECUTIVE_UNHEALTHY_THRESHOLD           = tostring(var.consecutive_unhealthy_threshold)           # consecutive unhealthy data points
      DATA_POINTS_EVAL_PERIOD                   = tostring(var.data_points_eval_period)                   # most recent datapoints to evaluate
      ZSCALER_USER_AGENT                        = var.zscaler_user_agent
    }
  }

  labels = {
    component = "resource-sync"
  }
}


# Cloud Scheduler Jobs (Optional)
resource "google_cloud_scheduler_job" "health_monitor" {
  count = var.enable_scheduler ? 1 : 0

  name             = "${var.name_prefix}-health-monitor-job-${var.resource_tag}"
  description      = "Triggers health monitoring every minute"
  schedule         = "* * * * *"
  time_zone        = "UTC"
  region           = var.region
  attempt_deadline = "600s"

  retry_config {
    retry_count = 1
  }

  http_target {
    http_method = "POST"
    uri         = google_cloudfunctions2_function.health_monitor_function.url

    oidc_token {
      service_account_email = var.byo_function_service_account != "" ? data.google_service_account.service_account_function_selected[0].email : google_service_account.service_account_function[0].email
    }
  }
}

resource "google_cloud_scheduler_job" "resource_sync" {
  count = var.enable_scheduler ? 1 : 0

  name             = "${var.name_prefix}-resource-sync-job-${var.resource_tag}"
  description      = "Triggers resource sync every 10 minutes"
  schedule         = "*/10 * * * *"
  time_zone        = "UTC"
  region           = var.region
  attempt_deadline = "600s"

  retry_config {
    retry_count = 1
  }

  http_target {
    http_method = "POST"
    uri         = google_cloudfunctions2_function.resource_sync_function.url

    oidc_token {
      service_account_email = var.byo_function_service_account != "" ? data.google_service_account.service_account_function_selected[0].email : google_service_account.service_account_function[0].email
    }
  }
}
