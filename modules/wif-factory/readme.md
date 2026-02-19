# GitHub Workload Identity Factory Module

This module provides a unified factory for creating Google Cloud **Workload Identity Federation (WIF)** pools/providers and **Service Accounts** together, with automatic mappings and scoped IAM role assignments. It combines the functionality of both the `service-account` and `github-workload-identity` modules into a single, cohesive configuration.

## Table of Contents

1. [Configuration Fields](#configuration-fields)
2. [Example Configuration](#example-configuration)
3. [Architecture & Design](#architecture--design)
4. [Usage](#usage)
5. [Outputs](#outputs)
6. [Notes](#notes)

---

## Configuration Fields

The module accepts a top-level variable `github_workload_identity_factory` of type `list(object)`. Each object entry supports the following fields (Terraform-style):

| Field | Type | Description | Required | Default |
| ----- | ---- | ----------- | -------- | ------- |
| `deploy` | `bool` | Whether to deploy this WIF + SA combo | Yes | - |
| **GitHub WIF Configuration** | | | | |
| `pool_id` | `string` | Workload identity pool ID | Yes | - |
| `pool_display_name` | `string` | Human-readable pool name (<=32 chars) | Yes | - |
| `provider_id` | `string` | Workload identity provider ID | Yes | - |
| `provider_display_name` | `string` | Human-readable provider name (<=32 chars) | Yes | - |
| `issuer_uri` | `string` | OIDC issuer URL | No | `https://token.actions.githubusercontent.com` |
| `repository_owner` | `string` | GitHub repository owner (used in attribute condition) | No | `intuitiveitp` |
| `attribute_mapping` | `map(string)` | OIDC attribute mapping for WIF provider | No | Standard GitHub attributes mapping |
| **Service Account Configuration** | | | | |
| `sa_account_id` | `string` | Service account ID/email prefix (6-30 chars, lowercase, hyphens) | Yes | - |
| `sa_display_name` | `string` | Human-readable service account name | Yes | - |
| `sa_description` | `string` | Service account description | No | `""` |
| `sa_disabled` | `bool` | Whether service account is disabled | No | `false` |
| **Scoped IAM Roles** | | | | |
| `project_id` | `string` | GCP project ID | Yes | - |
| `project_roles` | `list(string)` | Roles to bind at project scope | No | `[]` |
| `folder_id` | `string` | Folder ID for folder-scoped roles | No | `null` |
| `folder_roles` | `list(string)` | Roles to bind at folder scope | No | `[]` |
| `org_id` | `string` | Organization ID for org-scoped roles | No | `null` |
| `org_roles` | `list(string)` | Roles to bind at organization scope | No | `[]` |
| `billing_account_id` | `string` | Billing account ID for billing-scoped roles | No | `null` |
| `billing_account_roles` | `list(string)` | Roles to bind at billing account scope | No | `[]` |
| **SA to WIF Mapping** | | | | |
| `sa_mapping` | `map(object)` | Maps SA names to WIF provider attributes; each value has `sa_name` (string) and `attribute` (string) | No | `{}` |
| **General** | | | | |
| `labels` | `map(string)` | Labels for created resources | No | `{}` |

**Validation:**
- `pool_display_name` and `provider_display_name` must be ≤32 characters
- `sa_account_id` must be 6–30 characters and match regex `^[a-z0-9-]+$` (lowercase letters, numbers, hyphens only)

---

## Example Configuration

### Minimal Example

```hcl
github_workload_identity_factory = [
  {
    deploy              = true
    pool_id             = "sw-github-pool"
    pool_display_name   = "SW GitHub Pool"
    provider_id         = "github-actions"
    provider_display_name = "GitHub Actions"
    project_id          = "sw-dev-project"
    sa_account_id       = "gh-actions-sa"
    sa_display_name     = "GitHub Actions Service Account"
  }
]
```

### Typical Example (from your sample config)

```hcl
github_workload_identity_factory = [
  {
    deploy                    = true
    pool_id                   = "sw-github-action-pool"
    pool_display_name         = "sw-github-action-pool"
    provider_id               = "gh-action-provider"
    provider_display_name     = "gh-action-provider"
    project_id                = "melodic-furnace-403022"
    repository_owner          = "intuitivetp"

    # Service Account
    sa_account_id             = "sw-github-actions-wif-sa"
    sa_display_name           = "SW GitHub Actions WIF Service Account"
    sa_description            = "Service account for GitHub Actions with Workload Identity Federation"

    # Scoped Roles
    project_roles = [
      "roles/viewer",
      "roles/iam.workloadIdentityUser",
      "roles/storage.admin"
    ]
    folder_id = "folders/720473697353"
    folder_roles = [
      "roles/resourcemanager.folderCreator"
    ]
    org_id = "203589767236"
    org_roles = [
      "roles/resourcemanager.organizationViewer",
      "roles/resourcemanager.projectCreator",
      "roles/resourcemanager.projectIamAdmin",
      "roles/serviceusage.serviceUsageAdmin",
      "roles/billing.user"
    ]

    # WIF SA Mapping
    sa_mapping = {
      github-actions = {
        sa_name   = "projects/melodic-furnace-403022/serviceAccounts/sw-github-actions-wif-sa@melodic-furnace-403022.iam.gserviceaccount.com"
        attribute = "attribute.repository/intuitivetp"
      }
      gh-action-alchemy = {
        sa_name   = "projects/melodic-furnace-403022/serviceAccounts/sw-github-actions-wif-sa@melodic-furnace-403022.iam.gserviceaccount.com"
        attribute = "attribute.repository/intuitivetp/southwire-tf-infra-factory"
      }
    }
  }
]
```

### Full Example with Multiple Configs

```hcl
github_workload_identity_factory = [
  {
    deploy                    = true
    pool_id                   = "prod-github-pool"
    pool_display_name         = "Production GitHub Pool"
    provider_id               = "prod-gh-provider"
    provider_display_name     = "Production GitHub Provider"
    project_id                = "prod-project-123"
    repository_owner          = "myorg"
    issuer_uri                = "https://token.actions.githubusercontent.com"

    sa_account_id             = "prod-gh-deploy-sa"
    sa_display_name           = "Production GitHub Deploy SA"
    sa_description            = "Deploys to production via GitHub Actions"
    sa_disabled               = false

    project_roles = [
      "roles/iam.workloadIdentityUser",
      "roles/compute.admin",
      "roles/container.admin"
    ]
    org_id = "organizations/123456789"
    org_roles = [
      "roles/resourcemanager.projectCreator",
      "roles/resourcemanager.projectIamAdmin"
    ]

    sa_mapping = {
      deploy-prod = {
        sa_name   = "projects/prod-project-123/serviceAccounts/prod-gh-deploy-sa@prod-project-123.iam.gserviceaccount.com"
        attribute = "attribute.repository/myorg/*"
      }
    }

    labels = {
      team        = "platform"
      environment = "prod"
      owner       = "devops"
    }
  }
]
```

---

## Architecture & Design

The module is designed to simplify the common pattern of:
1. Creating a GitHub OIDC Workload Identity Pool
2. Creating a WIF Provider configured for GitHub
3. Creating a Service Account
4. Assigning scoped IAM roles to that Service Account across project/folder/org/billing scopes
5. Mapping the Service Account to the WIF Provider for GitHub Actions authentication

**Key Design Decisions:**
- **Unified Config**: Single object encapsulates both WIF and SA configuration, reducing configuration complexity and human error
- **Automatic Pool Deduplication**: If multiple service accounts reference the same `pool_id`, the pool is created only once
- **Flexible Role Scoping**: Supports project, folder, org, and billing account scope assignments in one place
- **Multiple SA Mappings**: The `sa_mapping` allows one or more GitHub repository patterns to authenticate as the same SA
- **Attribute Mapping**: Use `"*"` in the attribute to grant all identities in the pool access; use specific attributes like `"attribute.repository/owner/repo"` for fine-grained access

---

## Usage

1. Add the `github_workload_identity_factory` list to your environment config (Terragrunt/TFVars) following the examples above.
2. Run Terraform/Terragrunt for the module that references this module.

Example (module call snippet):

```hcl
module "gh_wif_factory" {
  source = "../../modules/github-workload-identity-factory"
  github_workload_identity_factory = var.github_workload_identity_factory
}
```

---

## Outputs

The module exports the following outputs:

- **`service_accounts`**: Map of created service accounts (email, unique_id, display_name)
- **`workload_identity_pools`**: Map of created WIF pools (name, workload_identity_pool_id, project_id)
- **`workload_identity_providers`**: Map of created WIF providers (name, provider_id, issuer_uri)
- **`sa_wif_mappings`**: Map of service account to WIF provider IAM bindings

---

## Notes

- **Validation**: All required fields must be present. Optional fields have sensible defaults.
- **Pool Existence Check**: The module checks if a pool with the same `pool_id` already exists in the project to avoid conflicts.
- **Scope Binding**: Only bind roles if the corresponding scope ID (`folder_id`, `org_id`, `billing_account_id`) and role list are provided.
- **Attribute Condition**: The WIF provider automatically adds an `attribute_condition` limiting access to the specified `repository_owner`. Ensure this matches your GitHub org name.
- **Service Account Email Formats**: In `sa_mapping`, `sa_name` can be:
  - Email format: `name@project.iam.gserviceaccount.com`
  - Resource path: `projects/PROJECT_ID/serviceAccounts/EMAIL`
  - Service Accounts resource: `serviceAccounts/EMAIL`
- **Least Privilege**: Assign only the minimum necessary roles across scopes. Review role permissions before applying.
- **Idempotence**: The module is idempotent; repeated applies with the same config will not recreate resources.


For advanced use cases (multiple pools, custom attribute conditions, or cross-project mappings), consider extending this module or using the underlying `service-account` and `github-workload-identity` modules directly.