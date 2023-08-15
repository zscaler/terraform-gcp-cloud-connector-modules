################################################################################
# Create Service Account to be assigned to Cloud Connector appliances
################################################################################
resource "google_service_account" "service_account_ccvm" {
  account_id   = "${var.name_prefix}-ccvm-sa-${var.resource_tag}"
  display_name = "${var.name_prefix}-ccvm-sa-${var.resource_tag}"
}


################################################################################
# Assign Service Account access to provided Secret Manager resource
################################################################################
resource "google_secret_manager_secret_iam_member" "member" {
  secret_id = var.secret_name
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.service_account_ccvm.email}"
}
