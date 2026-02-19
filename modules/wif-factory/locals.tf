locals {
  # Filter only the items to deploy
  configs_to_deploy = {
    for item in var.github_workload_identity_factory : "${item.project_id}-${item.sa_account_id}-${item.pool_id}" => item
    if item.deploy
  }

  # Flatten WIF provider configs (keyed by provider_id)
  wif_providers = {
    for key, item in local.configs_to_deploy : "${item.project_id}-${item.pool_id}-${item.provider_id}" => {
      pool_id               = item.pool_id
      pool_display_name     = item.pool_display_name
      provider_id           = item.provider_id
      provider_display_name = item.provider_display_name
      attribute_mapping     = item.attribute_mapping
      issuer_uri            = item.issuer_uri
      repository_owner      = item.repository_owner
      project_id            = item.project_id
    }
  }

  # Flatten pool configs (keyed by pool_id, de-duped)
  wif_pools = {
    for key, item in local.wif_providers : "${item.project_id}-${item.pool_id}" => {
      pool_id           = item.pool_id
      pool_display_name = item.pool_display_name
      project_id        = item.project_id
    }
  }

  # Flatten service account configs (keyed by sa_account_id)
  service_accounts = {
    for key, item in local.configs_to_deploy : "${item.project_id}-${item.sa_account_id}" => {
      project_id             = item.project_id
      account_id             = item.sa_account_id
      display_name           = item.sa_display_name
      description            = item.sa_description
      disabled               = item.sa_disabled
      project_roles          = item.project_roles
      folder_id              = item.folder_id
      folder_roles           = item.folder_roles
      org_id                 = item.org_id
      org_roles              = item.org_roles
      billing_account_id     = item.billing_account_id
      billing_account_roles  = item.billing_account_roles
    }
  }

  # Flatten SA-to-WIF mappings with pool resource names
  sa_to_wif_mappings = merge([
    for key, item in local.configs_to_deploy : {
      for sa_key, sa_val in item.sa_mapping : "${item.project_id}-${item.pool_id}-${sa_key}" => {
        sa_name      = sa_val.sa_name
        attribute    = sa_val.attribute
        pool_id      = item.pool_id
        project_id   = item.project_id
        pool_display_name = item.pool_display_name
      }
    }
  ]...)
}