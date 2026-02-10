variable "folders_objects" {
  description = "Configuration for organization and folder hierarchy"

  type = object({
    organization_id = string

    parent_folders = map(object({
      display_name = string
    }))

    sub_folders = map(object({
      display_name  = string
      parent_folder = string
    }))

    # nested_folders = map(object({
    #   display_name  = string
    #   parent_folder = string
    # }))
  })

  default = {
    organization_id = ""
    parent_folders  = {}
    sub_folders     = {}
    # nested_folders  = {}
  }

  # -----------------------------
  # Organization ID validation
  # -----------------------------
  validation {
    condition = (
      var.folders_objects.organization_id != "" &&
      can(regex("^[0-9]{6,}$", var.folders_objects.organization_id))
    )
    error_message = "organization_id must be a non-empty numeric GCP organization ID."
  }

  # ----------------------------------------
  # Sub-folder → Parent folder validation
  # ----------------------------------------
  validation {
    condition = alltrue([
      for _, sub in var.folders_objects.sub_folders :
      contains(
        keys(var.folders_objects.parent_folders),
        sub.parent_folder
      )
    ])
    error_message = "Each sub_folder.parent_folder must reference a valid key in parent_folders."
  }

#   # ----------------------------------------
#   # Nested-folder → Sub-folder validation
#   # ----------------------------------------
#   validation {
#     condition = alltrue([
#       for _, nested in var.folders_config.nested_folders :
#       contains(
#         keys(var.folders_config.sub_folders),
#         nested.parent_folder
#       )
#     ])
#     error_message = "Each nested_folder.parent_folder must reference a valid key in sub_folders."
#   }
 }