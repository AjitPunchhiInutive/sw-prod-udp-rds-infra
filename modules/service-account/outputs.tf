# ============================================================================
# Service Account Outputs
# ============================================================================

output "service_accounts" {
  description = "Map of service account details"
  value = {
    for sa_key, sa in google_service_account.service_accounts :
    sa_key => {
      email      = sa.email
      id         = sa.id
      name       = sa.name
      unique_id  = sa.unique_id
      account_id = sa.account_id
      project    = sa.project
      disabled   = sa.disabled
    }
  }
}

output "service_account_emails" {
  description = "Map of service account emails"
  value = {
    for sa_key, sa in google_service_account.service_accounts :
    sa_key => sa.email
  }
}

output "service_account_ids" {
  description = "Map of service account IDs"
  value = {
    for sa_key, sa in google_service_account.service_accounts :
    sa_key => sa.id
  }
}

output "service_account_unique_ids" {
  description = "Map of service account unique IDs (numeric)"
  value = {
    for sa_key, sa in google_service_account.service_accounts :
    sa_key => sa.unique_id
  }
}

output "service_account_names" {
  description = "Map of service account resource names"
  value = {
    for sa_key, sa in google_service_account.service_accounts :
    sa_key => sa.name
  }
}

# ============================================================================
# IAM Binding Outputs
# ============================================================================

output "project_iam_roles" {
  description = "Map of project-level IAM role bindings"
  value = {
    for binding_key, binding in google_project_iam_member.project_roles :
    binding_key => {
      project = binding.project
      role    = binding.role
      member  = binding.member
    }
  }
}

output "folder_iam_roles" {
  description = "Map of folder-level IAM role bindings"
  value = {
    for binding_key, binding in google_folder_iam_member.folder_roles :
    binding_key => {
      folder = binding.folder
      role   = binding.role
      member = binding.member
    }
  }
}

output "organization_iam_roles" {
  description = "Map of organization-level IAM role bindings"
  value = {
    for binding_key, binding in google_organization_iam_member.organization_roles :
    binding_key => {
      org_id = binding.org_id
      role   = binding.role
      member = binding.member
    }
  }
}

output "workload_identity_bindings" {
  description = "Map of Workload Identity bindings"
  value = {
    for binding_key, binding in google_service_account_iam_member.workload_identity :
    binding_key => {
      service_account_id = binding.service_account_id
      role               = binding.role
      member             = binding.member
    }
  }
}

# ============================================================================
# Service Account Key Outputs (Sensitive)
# ============================================================================

output "service_account_keys" {
  description = "Map of service account keys (SENSITIVE - contains private keys)"
  sensitive   = true
  value = {
    for sa_key, key in google_service_account_key.keys :
    sa_key => {
      id              = key.id
      name            = key.name
      private_key     = key.private_key
      public_key      = key.public_key
      valid_after     = key.valid_after
      valid_before    = key.valid_before
      key_algorithm   = key.key_algorithm
      private_key_type = key.private_key_type
    }
  }
}

output "service_account_key_ids" {
  description = "Map of service account key IDs"
  value = {
    for sa_key, key in google_service_account_key.keys :
    sa_key => key.id
  }
}

# ============================================================================
# Summary Output
# ============================================================================

output "summary" {
  description = "Summary of created service accounts and their configurations"
  value = {
    total_service_accounts    = length(google_service_account.service_accounts)
    project_iam_bindings      = length(google_project_iam_member.project_roles)
    folder_iam_bindings       = length(google_folder_iam_member.folder_roles)
    organization_iam_bindings = length(google_organization_iam_member.organization_roles)
    workload_identity_bindings = length(google_service_account_iam_member.workload_identity)
    keys_created              = length(google_service_account_key.keys)
  }
}
