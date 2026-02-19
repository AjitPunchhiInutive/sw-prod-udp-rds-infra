locals {
  organization_parent = "organizations/${var.folders_objects.organization_id}"

  parent_folders = var.folders_objects.parent_folders
  sub_folders    = var.folders_objects.sub_folders
  # nested_folders = var.folders_config.nested_folders

  # Map of parent folder names (resolved after creation)
  parent_folder_names = {
    for key, folder in google_folder.parent_folders :
    key => folder.name
  }

  # Map of sub-folder names (resolved after creation)
  sub_folder_names = {
    for key, folder in google_folder.sub_folders :
    key => folder.name
  }
}
