/**
 * Copyright 2024 Southwire
 *
 * Organization Policy Module - Outputs
 */

output "boolean_policies" {
  description = "Map of boolean organization policies that were created"
  value = {
    for policy_name, policy in google_organization_policy.boolean_policies :
    policy_name => {
      id         = policy.id
      constraint = policy.constraint
      enforced   = policy.boolean_policy[0].enforced
      etag       = policy.etag
      update_time = policy.update_time
    }
  }
}

output "list_policies_allow" {
  description = "Map of list organization policies with allow rules that were created"
  value = {
    for policy_name, policy in google_organization_policy.list_policies_allow :
    policy_name => {
      id         = policy.id
      constraint = policy.constraint
      values     = policy.list_policy[0].allow[0].values
      etag       = policy.etag
      update_time = policy.update_time
    }
  }
}

output "list_policies_allow_all" {
  description = "Map of list organization policies with allow all rules that were created"
  value = {
    for policy_name, policy in google_organization_policy.list_policies_allow_all :
    policy_name => {
      id         = policy.id
      constraint = policy.constraint
      allow_all  = policy.list_policy[0].allow[0].all
      etag       = policy.etag
      update_time = policy.update_time
    }
  }
}

output "list_policies_deny" {
  description = "Map of list organization policies with deny rules that were created"
  value = {
    for policy_name, policy in google_organization_policy.list_policies_deny :
    policy_name => {
      id         = policy.id
      constraint = policy.constraint
      values     = policy.list_policy[0].deny[0].values
      etag       = policy.etag
      update_time = policy.update_time
    }
  }
}

output "list_policies_deny_all" {
  description = "Map of list organization policies with deny all rules that were created"
  value = {
    for policy_name, policy in google_organization_policy.list_policies_deny_all :
    policy_name => {
      id         = policy.id
      constraint = policy.constraint
      deny_all   = policy.list_policy[0].deny[0].all
      etag       = policy.etag
      update_time = policy.update_time
    }
  }
}

output "parent_resource" {
  description = "The parent resource where policies are applied"
  value       = local.parent
}

output "policy_type" {
  description = "The type of resource where policies are applied"
  value       = var.policy_type
}

output "all_policy_ids" {
  description = "List of all organization policy IDs created by this module"
  value = concat(
    [for p in google_organization_policy.boolean_policies : p.id],
    [for p in google_organization_policy.list_policies_allow : p.id],
    [for p in google_organization_policy.list_policies_allow_all : p.id],
    [for p in google_organization_policy.list_policies_deny : p.id],
    [for p in google_organization_policy.list_policies_deny_all : p.id]
  )
}

output "policy_summary" {
  description = "Summary of all policies applied"
  value = {
    parent               = local.parent
    policy_type          = var.policy_type
    boolean_policy_count = length(google_organization_policy.boolean_policies)
    list_policy_count = (
      length(google_organization_policy.list_policies_allow) +
      length(google_organization_policy.list_policies_allow_all) +
      length(google_organization_policy.list_policies_deny) +
      length(google_organization_policy.list_policies_deny_all)
    )
    total_policy_count = (
      length(google_organization_policy.boolean_policies) +
      length(google_organization_policy.list_policies_allow) +
      length(google_organization_policy.list_policies_allow_all) +
      length(google_organization_policy.list_policies_deny) +
      length(google_organization_policy.list_policies_deny_all)
    )
  }
}
