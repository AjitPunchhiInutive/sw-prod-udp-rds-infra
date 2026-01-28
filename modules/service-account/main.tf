# ============================================================================
# Service Account Creation
# ============================================================================

resource "google_service_account" "service_accounts" {
  for_each = var.service_accounts

  account_id   = each.value.account_id
  display_name = each.value.display_name
  description  = each.value.description
  project      = var.project_id
  disabled     = lookup(each.value, "disabled", false)
}

# ============================================================================
# Project-Level IAM Bindings
# ============================================================================

resource "google_project_iam_member" "project_roles" {
  for_each = merge([
    for sa_key, sa in var.service_accounts : {
      for role in lookup(sa, "project_roles", []) :
      "${sa_key}-${role}" => {
        service_account = sa.account_id
        role            = role
        sa_key          = sa_key
      }
    }
  ]...)

  project = var.project_id
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.service_accounts[each.value.sa_key].email}"

  depends_on = [google_service_account.service_accounts]
}

# ============================================================================
# Project-Level IAM Bindings with Conditions
# ============================================================================

resource "google_project_iam_member" "project_roles_conditional" {
  for_each = merge([
    for sa_key, sa in var.service_accounts : {
      for idx, conditional_role in lookup(sa, "project_roles_conditional", []) :
      "${sa_key}-${conditional_role.role}-${idx}" => {
        service_account = sa.account_id
        role            = conditional_role.role
        sa_key          = sa_key
        condition       = conditional_role.condition
      }
    }
  ]...)

  project = var.project_id
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.service_accounts[each.value.sa_key].email}"

  condition {
    title       = each.value.condition.title
    description = lookup(each.value.condition, "description", "")
    expression  = each.value.condition.expression
  }

  depends_on = [google_service_account.service_accounts]
}

# ============================================================================
# Folder-Level IAM Bindings
# ============================================================================

resource "google_folder_iam_member" "folder_roles" {
  for_each = merge([
    for sa_key, sa in var.service_accounts : {
      for role in lookup(sa, "folder_roles", []) :
      "${sa_key}-${role}" => {
        service_account = sa.account_id
        role            = role
        sa_key          = sa_key
        folder_id       = sa.folder_id
      } if lookup(sa, "folder_id", null) != null
    }
  ]...)

  folder = each.value.folder_id
  role   = each.value.role
  member = "serviceAccount:${google_service_account.service_accounts[each.value.sa_key].email}"

  depends_on = [google_service_account.service_accounts]
}

# ============================================================================
# Organization-Level IAM Bindings
# ============================================================================

resource "google_organization_iam_member" "organization_roles" {
  for_each = merge([
    for sa_key, sa in var.service_accounts : {
      for role in lookup(sa, "organization_roles", []) :
      "${sa_key}-${role}" => {
        service_account = sa.account_id
        role            = role
        sa_key          = sa_key
        org_id          = sa.organization_id
      } if lookup(sa, "organization_id", null) != null
    }
  ]...)

  org_id = each.value.org_id
  role   = each.value.role
  member = "serviceAccount:${google_service_account.service_accounts[each.value.sa_key].email}"

  depends_on = [google_service_account.service_accounts]
}

# ============================================================================
# Service Account IAM Bindings (for Workload Identity)
# ============================================================================

resource "google_service_account_iam_member" "workload_identity" {
  for_each = merge([
    for sa_key, sa in var.service_accounts : {
      for idx, wi in lookup(sa, "workload_identity_bindings", []) :
      "${sa_key}-${idx}" => {
        sa_key           = sa_key
        role             = wi.role
        namespace        = wi.namespace
        ksa_name         = wi.ksa_name
        gke_project_id   = lookup(wi, "gke_project_id", var.project_id)
      }
    }
  ]...)

  service_account_id = google_service_account.service_accounts[each.value.sa_key].name
  role               = each.value.role
  member             = "serviceAccount:${each.value.gke_project_id}.svc.id.goog[${each.value.namespace}/${each.value.ksa_name}]"

  depends_on = [google_service_account.service_accounts]
}

# ============================================================================
# Custom IAM Member Bindings
# ============================================================================

resource "google_service_account_iam_member" "custom_members" {
  for_each = merge([
    for sa_key, sa in var.service_accounts : {
      for idx, binding in lookup(sa, "custom_iam_members", []) :
      "${sa_key}-${binding.role}-${idx}" => {
        sa_key = sa_key
        role   = binding.role
        member = binding.member
      }
    }
  ]...)

  service_account_id = google_service_account.service_accounts[each.value.sa_key].name
  role               = each.value.role
  member             = each.value.member

  depends_on = [google_service_account.service_accounts]
}

# ============================================================================
# Service Account Keys (NOT RECOMMENDED for Production)
# Only use for testing or when absolutely necessary
# ============================================================================

resource "google_service_account_key" "keys" {
  for_each = {
    for sa_key, sa in var.service_accounts :
    sa_key => sa
    if lookup(sa, "create_key", false) && var.allow_key_creation
  }

  service_account_id = google_service_account.service_accounts[each.key].name
  key_algorithm      = lookup(each.value, "key_algorithm", "KEY_ALG_RSA_2048")
  private_key_type   = lookup(each.value, "private_key_type", "TYPE_GOOGLE_CREDENTIALS_FILE")

  depends_on = [google_service_account.service_accounts]
}
