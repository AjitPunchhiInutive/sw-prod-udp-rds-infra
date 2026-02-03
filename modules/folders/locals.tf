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
    },
    {
      for key, folder in google_folder.nested_folders :
      key => {
        id           = folder.name
        display_name = folder.display_name
        parent       = folder.parent
        type         = "nested"
      }
    }

  )
}

