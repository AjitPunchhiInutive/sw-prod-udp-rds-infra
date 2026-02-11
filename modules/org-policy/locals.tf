locals {
  folder_boolean_policies = var.folder_org_policies.deploy ? [
    for constraint, enforce in var.folder_org_policies.policy_boolean : {
      key        = constraint
      folder_id  = var.folder_org_policies.folder_id
      constraint = constraint
      enforce    = enforce
    }
  ] : []

  folder_list_policies = var.folder_org_policies.deploy ? [
    for constraint, config in var.folder_org_policies.policy_list : {
      key                 = constraint
      folder_id           = var.folder_org_policies.folder_id
      constraint          = constraint
      inherit_from_parent = config.inherit_from_parent
      suggested_value     = config.suggested_value
      status              = config.status
      values              = config.values
    }
  ] : []
}