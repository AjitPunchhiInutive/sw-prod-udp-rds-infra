/**
 * Copyright 2024 Southwire
 *
 * Organization Policy Module - Variables
 * This module manages GCP Organization Policies
 */

variable "organization_id" {
  description = "The organization ID to apply policies to"
  type        = string
  default     = ""
}

variable "folder_id" {
  description = "The folder ID to apply policies to (optional, mutually exclusive with organization_id and project_id)"
  type        = string
  default     = null
}

variable "project_id" {
  description = "The project ID to apply policies to (optional, mutually exclusive with organization_id and folder_id)"
  type        = string
  default     = null
}

variable "boolean_policies" {
  description = "Map of boolean organization policies to enforce"
  type = map(object({
    enforce = bool
  }))
  default = {}
}

variable "list_policies" {
  description = "Map of list organization policies to configure"
  type = map(object({
    inherit_from_parent = optional(bool, false)
    suggested_value     = optional(string)
    allow = optional(object({
      all    = optional(bool, false)
      values = optional(list(string), [])
    }))
    deny = optional(object({
      all    = optional(bool, false)
      values = optional(list(string), [])
    }))
  }))
  default = {}
}

variable "policy_type" {
  description = "Type of resource to apply policies to (organization, folder, or project)"
  type        = string
  default     = "organization"
  validation {
    condition     = contains(["organization", "folder", "project"], var.policy_type)
    error_message = "Policy type must be one of: organization, folder, project."
  }
}

variable "exclude_folders" {
  description = "List of folder IDs to exclude from policy application"
  type        = list(string)
  default     = []
}

variable "exclude_projects" {
  description = "List of project IDs to exclude from policy application"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to policies for organization and tracking"
  type        = map(string)
  default     = {}
}
