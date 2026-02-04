# Parent Folders (Direct children of organization)
resource "google_folder" "parent_folders" {
  for_each = var.parent_folders
  
  display_name = each.value.display_name
  parent       = "organizations/203589767236"
}

# Sub-Folders (Children of parent folders)
resource "google_folder" "sub_folders" {
  for_each = var.sub_folders
  
  display_name = each.value.display_name
  parent       = google_folder.parent_folders[each.value.parent_folder].name
  depends_on = [google_folder.parent_folders]

  
}

# Nested Folders (Children of sub-folders )
resource "google_folder" "nested_folders" {
  for_each = var.nested_folders
  
  display_name = each.value.display_name
  parent       = google_folder.sub_folders[each.value.parent_folder].name
  depends_on = [google_folder.sub_folders]
}
