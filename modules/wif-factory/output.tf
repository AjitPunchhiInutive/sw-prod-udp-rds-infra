output "service_accounts" {
  description = "Map of created service accounts with email and metadata"
  value = {
    for key, sa in google_service_account.github_wif : key => {
      email       = sa.email
      unique_id   = sa.unique_id
      name        = sa.name
      display_name= sa.display_name
    }
  }
  depends_on = [google_service_account.github_wif]
}

output "workload_identity_pools" {
  description = "Map of created Workload Identity Pools"
  value = {
    for key, pool in google_iam_workload_identity_pool.github : key => {
      name                      = pool.name
      workload_identity_pool_id = pool.workload_identity_pool_id
      project_id                = pool.project
    }
  }
  depends_on = [google_iam_workload_identity_pool.github]
}

output "workload_identity_providers" {
  description = "Map of created Workload Identity Providers"
  value = {
    for key, provider in google_iam_workload_identity_pool_provider.github : key => {
      name                  = provider.name
      provider_id           = provider.workload_identity_pool_provider_id
      issuer_uri            = provider.oidc[0].issuer_uri
    }
  }
  depends_on = [google_iam_workload_identity_pool_provider.github]
}

output "sa_wif_mappings" {
  description = "Mapping of service accounts to WIF provider attributes"
  value = {
    for key, mapping in google_service_account_iam_member.github_workload_identity : key => {
      service_account = mapping.service_account_id
      member          = mapping.member
    }
  }
}