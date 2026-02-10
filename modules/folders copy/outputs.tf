#### oytput#####

output "parent_folder_ids" {
  description = "Map of parent folder keys to folder IDs"
  value = {
    for key, folder in google_folder.parent_folders :
    key => folder.name
  }
}

output "sub_folder_ids" {
  description = "Map of sub-folder keys to folder IDs"
  value = {
    for key, folder in google_folder.sub_folders :
    key => folder.name
  }
}

# output "nested_folders_ids" {
#   description = "Map of nested-folder keys to folder IDs"
#   value = {
#     for key, folder in google_folder.nested_folders :
#     key => folder.name
#   }
# }
