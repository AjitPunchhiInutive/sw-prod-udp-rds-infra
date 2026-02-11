output "boolean_policy_ids" {
  description = "IDs of the boolean organization policies"
  value       = { for k, v in google_folder_organization_policy.boolean_policies : k => v.id }
}

output "list_policy_ids" {
  description = "IDs of the list organization policies"
  value       = { for k, v in google_folder_organization_policy.list_policies : k => v.id }
}
