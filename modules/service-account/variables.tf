# ============================================================================
# Required Variables
# ============================================================================

variable "project_id" {
  description = "The GCP project ID where service accounts will be created"
  type        = string

  validation {
    condition     = length(var.project_id) > 0
    error_message = "Project ID must not be empty."
  }
}

variable "service_accounts" {
  description = <<-EOF
    Map of service accounts to create with their configurations.
    
    Each service account can have:
    - account_id: (Required) The account ID (email prefix) for the service account
    - display_name: (Required) Human-readable display name
    - description: (Required) Description of the service account's purpose
    - disabled: (Optional) Whether the service account is disabled. Default: false
    - project_roles: (Optional) List of project-level IAM roles
    - project_roles_conditional: (Optional) List of conditional IAM bindings with conditions
    - folder_roles: (Optional) List of folder-level IAM roles (requires folder_id)
    - folder_id: (Optional) Folder ID for folder-level roles
    - organization_roles: (Optional) List of organization-level IAM roles (requires organization_id)
    - organization_id: (Optional) Organization ID for organization-level roles
    - workload_identity_bindings: (Optional) List of Workload Identity bindings for GKE
    - custom_iam_members: (Optional) List of custom IAM member bindings
    - create_key: (Optional) Whether to create a service account key. Default: false (NOT RECOMMENDED)
    
    Example:
    service_accounts = {
      compute_instance = {
        account_id   = "compute-instance-sa"
        display_name = "Compute Instance Service Account"
        description  = "Service account for Compute Engine instances"
        project_roles = [
          "roles/logging.logWriter",
          "roles/monitoring.metricWriter"
        ]
      }
    }
  EOF
  
  type = map(object({
    account_id   = string
    display_name = string
    description  = string
    disabled     = optional(bool, false)

    # Project-level roles
    project_roles = optional(list(string), [])
    
    # Conditional project-level roles
    project_roles_conditional = optional(list(object({
      role = string
      condition = object({
        title       = string
        description = optional(string, "")
        expression  = string
      })
    })), [])

    # Folder-level roles
    folder_roles = optional(list(string), [])
    folder_id    = optional(string, null)

    # Organization-level roles
    organization_roles = optional(list(string), [])
    organization_id    = optional(string, null)

    # Workload Identity for GKE
    workload_identity_bindings = optional(list(object({
      role           = string
      namespace      = string
      ksa_name       = string
      gke_project_id = optional(string)
    })), [])

    # Custom IAM member bindings
    custom_iam_members = optional(list(object({
      role   = string
      member = string
    })), [])

    # Service Account Key (NOT RECOMMENDED)
    create_key       = optional(bool, false)
    key_algorithm    = optional(string, "KEY_ALG_RSA_2048")
    private_key_type = optional(string, "TYPE_GOOGLE_CREDENTIALS_FILE")
  }))

  validation {
    condition = alltrue([
      for sa_key, sa in var.service_accounts :
      can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", sa.account_id))
    ])
    error_message = "Service account IDs must be between 6-30 characters, start with a letter, and contain only lowercase letters, numbers, and hyphens."
  }

  validation {
    condition = alltrue([
      for sa_key, sa in var.service_accounts :
      length(sa.display_name) > 0 && length(sa.display_name) <= 100
    ])
    error_message = "Display names must be between 1-100 characters."
  }

  validation {
    condition = alltrue([
      for sa_key, sa in var.service_accounts :
      length(sa.description) > 0 && length(sa.description) <= 256
    ])
    error_message = "Descriptions must be between 1-256 characters."
  }
}

# ============================================================================
# Optional Variables
# ============================================================================

variable "allow_key_creation" {
  description = "Global flag to allow service account key creation. Set to false in production. Default: false"
  type        = bool
  default     = false
}

variable "labels" {
  description = "Labels to apply to all resources"
  type        = map(string)
  default     = {}
}
