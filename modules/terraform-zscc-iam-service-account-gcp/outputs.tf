output "service_account" {
  description = "CC VM Service Account Principal"
  value       = google_service_account.service_account_ccvm.email
}
