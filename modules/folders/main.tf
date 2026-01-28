# Parent Folders (Direct children of organization)
resource "google_folder" "parent_folders" {
  for_each = var.parent_folders
  
  display_name = each.value.display_name
  parent       = "organizations/${var.organization_id}"
}

# Sub-Folders (Children of parent folders)
resource "google_folder" "sub_folders" {
  for_each = var.sub_folders
  
  display_name = each.value.display_name
  parent       = google_folder.parent_folders[each.value.parent_folder].name
  
  depends_on = [google_folder.parent_folders]
}

# All folders combined for easy reference
locals {
  all_folders = merge(
    {
      for key, folder in google_folder.parent_folders :
      key => {
        id           = folder.name
        display_name = folder.display_name
        parent       = folder.parent
        type         = "parent"
      }
    },
    {
      for key, folder in google_folder.sub_folders :
      key => {
        id           = folder.name
        display_name = folder.display_name
        parent       = folder.parent
        type         = "sub"
      }
    }
  )
}
