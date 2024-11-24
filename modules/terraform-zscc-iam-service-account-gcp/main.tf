################################################################################
# Project ID/Name lookup to convert to number for project association to
# google_secret_manager_secret_iam_member
################################################################################
data "google_project" "project" {
  project_id = var.project
}

################################################################################
# Create Service Account to be assigned to Cloud Connector appliances
################################################################################
resource "google_service_account" "service_account_ccvm" {
  count        = var.byo_ccvm_service_account != "" ? 0 : 1
  account_id   = var.service_account_id
  display_name = var.service_account_display_name
  project      = var.project
}

# Or use existing Service Account
data "google_service_account" "service_account_ccvm_selected" {
  count      = var.byo_ccvm_service_account != "" ? 1 : 0
  account_id = var.byo_ccvm_service_account
}

################################################################################
# Assign Service Account access to provided Secret Manager resource
################################################################################
### If var.secret_name is popoulated AND not bringing an existing SA, then create SA and assign it Secret Accessor role to that Secret ID
resource "google_secret_manager_secret_iam_member" "member" {
  count     = var.secret_name != "" && var.byo_ccvm_service_account == "" ? 1 : 0
  secret_id = var.secret_name
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.service_account_ccvm[0].email}"
  project   = data.google_project.project.number
}

################################################################################
# Assign Service Account the Service Account Token Creator role 
################################################################################
### If var.hcp_vault_enabled is true AND not bringing an existing SA, then create SA and Service Account Token Creator Role for HCP Vault
resource "google_service_account_iam_member" "iam_token_creator" {
  count              = var.hcp_vault_enabled && var.byo_ccvm_service_account == "" ? 1 : 0
  service_account_id = google_service_account.service_account_ccvm[0].name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${google_service_account.service_account_ccvm[0].email}"
}
