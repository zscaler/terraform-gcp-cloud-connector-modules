output "service_account" {
  description = "CC VM Service Account Principal"
  value       = try(data.google_service_account.service_account_ccvm_selected[0].email, google_service_account.service_account_ccvm[0].email)
}
