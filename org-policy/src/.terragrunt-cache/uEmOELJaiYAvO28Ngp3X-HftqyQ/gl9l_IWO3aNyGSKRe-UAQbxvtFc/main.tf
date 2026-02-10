# Boolean Organization Policies
# These policies enforce or disable specific boolean constraints
resource "google_organization_policy" "boolean_policies" {
  for_each = local.boolean_policies_map

  org_id     = var.policy_type == "organization" ? var.organization_id : null
  constraint = each.key

  boolean_policy {
    enforced = each.value.enforce
  }
}

# List Organization Policies with Allow Rules
# These policies allow specific values for list-based constraints
resource "google_organization_policy" "list_policies_allow" {
  for_each = {
    for policy_name, policy_config in local.list_policies_map :
    policy_name => policy_config
    if policy_config.allow != null && !try(policy_config.allow.all, false)
  }

  org_id     = var.policy_type == "organization" ? var.organization_id : null

  constraint = each.key

  list_policy {
    inherit_from_parent = each.value.inherit_from_parent
    suggested_value     = each.value.suggested_value

    allow {
      values = each.value.allow.values
    }
  }
}

# List Organization Policies with Allow All
# These policies allow all values for list-based constraints
resource "google_organization_policy" "list_policies_allow_all" {
  for_each = {
    for policy_name, policy_config in local.list_policies_map :
    policy_name => policy_config
    if policy_config.allow != null && try(policy_config.allow.all, false)
  }

  org_id     = var.policy_type == "organization" ? var.organization_id : null
  constraint = each.key

  list_policy {
    inherit_from_parent = each.value.inherit_from_parent
    suggested_value     = each.value.suggested_value

    allow {
      all = true
    }
  }
}

# List Organization Policies with Deny Rules
# These policies deny specific values for list-based constraints
resource "google_organization_policy" "list_policies_deny" {
  for_each = {
    for policy_name, policy_config in local.list_policies_map :
    policy_name => policy_config
    if policy_config.deny != null && !try(policy_config.deny.all, false)
  }

  org_id     = var.policy_type == "organization" ? var.organization_id : null
  constraint = each.key

  list_policy {
    inherit_from_parent = each.value.inherit_from_parent
    suggested_value     = each.value.suggested_value

    deny {
      values = each.value.deny.values
    }
  }
}

# List Organization Policies with Deny All
# These policies deny all values for list-based constraints
resource "google_organization_policy" "list_policies_deny_all" {
  for_each = {
    for policy_name, policy_config in local.list_policies_map :
    policy_name => policy_config
    if policy_config.deny != null && try(policy_config.deny.all, false)
  }

  org_id     = var.policy_type == "organization" ? var.organization_id : null
  constraint = each.key

  list_policy {
    inherit_from_parent = each.value.inherit_from_parent
    suggested_value     = each.value.suggested_value

    deny {
      all = true
    }
  }
}
