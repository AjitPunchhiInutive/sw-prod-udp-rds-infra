/**
 * Simple Folders Module - Variables
 */

variable "organization_id" {
  description = "GCP Organization ID"
  type        = string
  default     = ""
}

variable "parent_folders" {
  description = "Parent folders to create (direct children of organization)"
  type = map(object({
    display_name = string
  }))
  default = {}
}

variable "sub_folders" {
  description = "Sub-folders to create (children of parent folders)"
  type = map(object({
    display_name  = string
    parent_folder = string  # Key of the parent folder
  }))
  default = {}
}
variable "nested_folders" {
  description = "Nested-folders to create (children of sub folders)"
  type = map(object({
    display_name  = string
    parent_folder = string  # Key of the parent folder
  }))
  default = {}
}

