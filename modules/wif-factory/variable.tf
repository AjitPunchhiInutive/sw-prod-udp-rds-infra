/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

variable "github_workload_identity_factory" {
  description = "Consolidated configuration for GitHub Workload Identity + Service Account factory"
  type = list(object({
    deploy                    = bool             #(Required) Whether to deploy the WIF + SA
    pool_id                   = string           #(Required) Workload identity pool ID
    pool_display_name         = string           #(Required) Display name for pool (<=32 chars)
    provider_id               = string           #(Required) Workload identity provider ID
    provider_display_name     = string           #(Required) Display name for provider (<=32 chars)
    project_id                = string           #(Required) GCP project ID
    repository_owner          = optional(string, "intuitiveitp") #(Optional) GitHub repository owner
    attribute_mapping         = optional(map(string), {
      "google.subject"       = "assertion.sub"
      "attribute.actor"      = "assertion.actor"
      "attribute.aud"        = "assertion.aud"
      "attribute.repository" = "assertion.repository"
    }) #(Optional) Attribute mapping for WIF provider

    # Service Account configuration
    sa_account_id             = string           #(Required) Service account ID (email prefix)
    sa_display_name           = string           #(Required) Service account display name
    sa_description            = optional(string, "") #(Optional) Service account description
    sa_disabled               = optional(bool, false) #(Optional) Whether service account is disabled

    # Scoped IAM roles
    project_roles             = optional(list(string), [])          #(Optional) Roles at project scope
    folder_id                 = optional(string)                     #(Optional) Folder for folder-scoped roles
    folder_roles              = optional(list(string), [])          #(Optional) Roles at folder scope
    org_id                    = optional(string)                     #(Optional) Organization for org-scoped roles
    org_roles                 = optional(list(string), [])          #(Optional) Roles at org scope
    billing_account_id        = optional(string)                     #(Optional) Billing account for billing-scoped roles
    billing_account_roles     = optional(list(string), [])          #(Optional) Roles at billing account scope

    # Service Account mapping to WIF
    sa_mapping                = optional(map(object({
      sa_name   = string
      attribute = string
    })), {})                                                         #(Optional) SA to WIF provider attribute mapping

    issuer_uri                = optional(string, "https://token.actions.githubusercontent.com") #(Optional) GitHub OIDC issuer
  }))
  default = []

  validation {
    condition = alltrue([
      for item in var.github_workload_identity_factory : (
        item.deploy == false || (
          length(item.pool_display_name) <= 32 &&
          length(item.provider_display_name) <= 32 &&
          length(item.sa_account_id) >= 6 && length(item.sa_account_id) <= 30 &&
          can(regex("^[a-z0-9-]+$", item.sa_account_id))
        )
      )
    ])
    error_message = "pool_display_name and provider_display_name must be <=32 chars; sa_account_id must be 6-30 chars with lowercase letters, numbers, and hyphens."
  }
}