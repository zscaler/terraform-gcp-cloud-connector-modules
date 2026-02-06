output "health_monitor_function_uri" {
  description = "URI of the Cloud Function (Gen 2)"
  value       = google_cloudfunctions2_function.health_monitor_function.service_config[0].uri
}

output "health_monitor_function_url" {
  description = "URL of the Cloud Function (Gen 2)"
  value       = google_cloudfunctions2_function.health_monitor_function.url
}
output "health_monitor_function_id" {
  description = "ID of the Cloud Function (Gen 2)"
  value       = google_cloudfunctions2_function.health_monitor_function.id
}

output "resource_sync_function_uri" {
  description = "URI of the Cloud Function (Gen 2)"
  value       = google_cloudfunctions2_function.resource_sync_function.service_config[0].uri
}

output "resource_sync_function_url" {
  description = "URL of the Cloud Function (Gen 2)"
  value       = google_cloudfunctions2_function.resource_sync_function.url
}

output "resource_sync_function_id" {
  description = "ID of the resource sync function"
  value       = google_cloudfunctions2_function.resource_sync_function.id
}

output "scheduler_jobs" {
  description = "Names of created scheduler jobs"
  value = var.enable_scheduler ? {
    health_monitor = google_cloud_scheduler_job.health_monitor[0].name
    resource_sync  = google_cloud_scheduler_job.resource_sync[0].name
  } : {}
}

output "storage_bucket_name" {
  description = "Name of the Storage Bucket used for Cloud Function source code"
  value       = var.byo_storage_bucket ? data.google_storage_bucket.existing_storage_bucket[0].name : google_storage_bucket.cc_storage_bucket[0].name
}
