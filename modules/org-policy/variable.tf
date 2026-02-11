variable "folder_org_policies" {
  description = "Folder org policies configuration"
  type = object({
    deploy         = bool
    folder_id      = string
    policy_boolean = optional(map(bool), {})
    policy_list = optional(map(object({
      inherit_from_parent = optional(bool, false)
      suggested_value     = optional(string, "")
      status              = bool
      values              = list(string)
    })), {})
  })
}