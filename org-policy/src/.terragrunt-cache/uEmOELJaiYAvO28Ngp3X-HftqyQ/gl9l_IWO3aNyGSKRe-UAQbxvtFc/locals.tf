/**
 * Copyright 2024 Southwire
 *
 * Organization Policy Module - Local Values
 */

locals {
  # Determine the parent resource based on policy type
  parent = var.policy_type == "organization" ? "organizations/${var.organization_id}" : (
    var.policy_type == "folder" ? "folders/${var.folder_id}" : "projects/${var.project_id}"
  )

  # Boolean policies with parent reference
  boolean_policies_map = {
    for policy_name, policy_config in var.boolean_policies :
    policy_name => {
      parent  = local.parent
      enforce = policy_config.enforce
    }
  }

  # List policies with parent reference
  list_policies_map = {
    for policy_name, policy_config in var.list_policies :
    policy_name => {
      parent              = local.parent
      inherit_from_parent = policy_config.inherit_from_parent
      suggested_value     = policy_config.suggested_value
      allow               = policy_config.allow
      deny                = policy_config.deny
    }
  }

  # Common tags with defaults
  common_tags = merge(
    {
      managed_by  = "terraform"
      module      = "org-policy"
      environment = "production"
    },
    var.tags
  )

  # Policy exclusions
  exclusions = {
    folders  = var.exclude_folders
    projects = var.exclude_projects
  }
}
