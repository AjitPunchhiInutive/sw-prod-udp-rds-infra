# Create Workload Identity Pool (one per pool_id, project id)
resource "google_iam_workload_identity_pool" "github" {
  for_each = local.wif_pools

  provider                  = google-beta
  project                   = each.value.project_id
  workload_identity_pool_id = each.value.pool_id
  display_name              = each.value.pool_display_name
  description               = "GitHub Actions workload identity pool"
  disabled                  = false
}

# Create Workload Identity Provider (one per provider_id)
resource "google_iam_workload_identity_pool_provider" "github" {
  for_each = local.wif_providers

  provider                           = google-beta
  project                            = each.value.project_id
  workload_identity_pool_id          = each.value.pool_id
  workload_identity_pool_provider_id = each.value.provider_id
  display_name                       = each.value.provider_display_name
  description                        = "GitHub OIDC Workload Identity Provider"
  attribute_mapping                  = each.value.attribute_mapping
  attribute_condition                = "assertion.repository_owner == '${each.value.repository_owner}'"

  oidc {
    issuer_uri = each.value.issuer_uri
  }

  depends_on = [google_iam_workload_identity_pool.github]
}

# Create Service Accounts
resource "google_service_account" "github_wif" {
  for_each = local.service_accounts

  provider        = google
  project         = each.value.project_id
  account_id      = each.value.account_id
  display_name    = each.value.display_name
  description     = each.value.description
  disabled        = each.value.disabled
  create_ignore_already_exists = true

  depends_on = []
}

# Bind service account project roles
resource "google_project_iam_member" "sa_project_roles" {
  for_each = merge([
    for sa_key, sa_val in local.service_accounts : {
      for role in sa_val.project_roles : "${sa_key}-${role}" => {
        sa_email  = google_service_account.github_wif[sa_key].email
        role      = role
        project   = sa_val.project_id
      }
    }
  ]...)

  project = each.value.project
  role    = each.value.role
  member  = "serviceAccount:${each.value.sa_email}"

  depends_on = [google_service_account.github_wif]
}

# Bind service account folder roles
resource "google_folder_iam_member" "sa_folder_roles" {
  for_each = merge([
    for sa_key, sa_val in local.service_accounts : {
      for role in sa_val.folder_roles : "${sa_key}-${role}" => {
        sa_email  = google_service_account.github_wif[sa_key].email
        role      = role
        folder_id = sa_val.folder_id
      }
      if sa_val.folder_id != null && length(sa_val.folder_roles) > 0
    }
  ]...)

  folder = each.value.folder_id
  role   = each.value.role
  member = "serviceAccount:${each.value.sa_email}"

  depends_on = [google_service_account.github_wif]
}

# Bind service account org roles
resource "google_organization_iam_member" "sa_org_roles" {
  for_each = merge([
    for sa_key, sa_val in local.service_accounts : {
      for role in sa_val.org_roles : "${sa_key}-${role}" => {
        sa_email = google_service_account.github_wif[sa_key].email
        role     = role
        org_id   = sa_val.org_id
      }
      if sa_val.org_id != null && length(sa_val.org_roles) > 0
    }
  ]...)

  org_id = each.value.org_id
  role   = each.value.role
  member = "serviceAccount:${each.value.sa_email}"

  depends_on = [google_service_account.github_wif]
}

# Bind service account billing account roles
resource "google_billing_account_iam_member" "sa_billing_roles" {
  for_each = merge([
    for sa_key, sa_val in local.service_accounts : {
      for role in sa_val.billing_account_roles : "${sa_key}-${role}" => {
        sa_email           = google_service_account.github_wif[sa_key].email
        role               = role
        billing_account_id = sa_val.billing_account_id
      }
      if sa_val.billing_account_id != null && length(sa_val.billing_account_roles) > 0
    }
  ]...)

  billing_account_id = each.value.billing_account_id
  role               = each.value.role
  member             = "serviceAccount:${each.value.sa_email}"

  depends_on = [google_service_account.github_wif]
}

# Bind service accounts to WIF provider via Service Account IAM
resource "google_service_account_iam_member" "github_workload_identity" {
  for_each = local.sa_to_wif_mappings

  service_account_id = each.value.sa_name
  role               = "roles/iam.workloadIdentityUser"

  member = each.value.attribute == "*" ? "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github["${each.value.project_id}-${each.value.pool_id}"].name}/*" : "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github["${each.value.project_id}-${each.value.pool_id}"].name}/${each.value.attribute}"

  depends_on = [
    google_iam_workload_identity_pool_provider.github,
    google_service_account.github_wif
  ]
}