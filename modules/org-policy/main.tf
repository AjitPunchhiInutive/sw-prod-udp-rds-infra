resource "google_folder_organization_policy" "boolean_policies" {
  for_each = { for p in local.folder_boolean_policies : p.key => p }

  folder     = each.value.folder_id
  constraint = each.value.constraint

  boolean_policy {
    enforced = each.value.enforce
  }
}

resource "google_folder_organization_policy" "list_policies" {
  for_each = { for p in local.folder_list_policies : p.key => p }

  folder     = each.value.folder_id
  constraint = each.value.constraint

  list_policy {
    inherit_from_parent = each.value.inherit_from_parent
    suggested_value     = each.value.suggested_value

    dynamic "allow" {
      for_each = each.value.status ? [1] : []
      content {
        values = each.value.values
      }
    }

    dynamic "deny" {
      for_each = !each.value.status ? [1] : []
      content {
        values = each.value.values
      }
    }
  }
}
