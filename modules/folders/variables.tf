/**
 * Simple Folders Module - Variables
 */

variable "organization_id" {
  description = "GCP Organization ID"
  type        = string
  
  validation {
    condition     = can(regex("^[0-9]+$", var.organization_id))
    error_message = "Organization ID must be numeric."
  }
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
