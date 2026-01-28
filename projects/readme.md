# GCP Project Configuration

Welcome to the **GCP Resource Foundry** repository! This repository provides a structured approach to managing Google Cloud Platform (GCP) projects across different environments using Terraform. This README offers a comprehensive guide on how to configure a JSON file for automating project creation, IAM policies, billing, networking, and more.

This guide follows best practices for Terraform configuration, ensuring modularity, reusability, and clarity in managing GCP resources.

## Table of Contents

1. [Repository Structure](#repository-structure)
2. [Configuration Structure](#configuration-structure)
3. [Project Configuration Fields](#project-configuration-fields)
4. [Example JSON Configuration](#example-json-configuration)
   - [1. Minimal Configuration (Only Required Fields)](#1-minimal-configuration-only-required-fields)
   - [2. Typical Configuration (Required + Some Optional Fields)](#2-typical-configuration-required--some-optional-fields)
   - [3. Full Configuration (All Optional Fields Included)](#3-full-configuration-all-optional-fields-included)
5. [Usage](#usage)
6. [Notes](#notes)

---

## Repository Structure

```
southwire-infra/
├── global.hcl                 # Global Terragrunt configuration
├── terragrunt.hcl             # Root Terragrunt configuration
├── modules/
│   └── project/               # Shared project module
│       ├── locals.tf          # Local values
│       ├── main.tf            # Main resource definitions
│       ├── output.tf          # Output values
│       └── variable.tf        # Variable definitions
└── projects/                  # Environment-specific project configurations
    ├── dev/                   # Development environment
    │   ├── env.hcl            # Environment-specific variables
    │   ├── project.hcl        # Project configuration
    │   ├── config/            # JSON configuration files
    │   │   ├── prj-test-udp-rds.json
    │   │   ├── prj-test-udp-eds.json
    │   │   └── prj-test-udp-ods.json
    │   └── src/
    │       └── terragrunt.hcl  # Terragrunt execution configuration
    ├── prod/                  # Production environment
    │   ├── env.hcl
    │   ├── project.hcl
    │   ├── config/            # JSON configuration files
    │   │   ├── prj-prod-udp-rds.json
    │   │   ├── prj-prod-udp-eds.json
    │   │   └── prj-prod-udp-ods.json
    │   └── src/
    │       └── terragrunt.hcl
    └── test/                  # Test environment
        ├── env.hcl
        ├── project.hcl
        ├── config/            # JSON configuration files
        │   ├── prj-test-udp-rds.json
        │   ├── prj-test-udp-eds.json
        │   └── prj-test-udp-ods.json
        └── src/
            ├── terragrunt.hcl
            └── pipeline.yml    # Azure DevOps CI/CD pipeline (Test environment only)
```

---

## Configuration Structure

The configuration is a JSON object. Each object defines the parameters for creating and managing a GCP project, including IAM, billing, networking, service accounts, policies, and budgets.

### Environment Folders

- **dev/**: Development environment for testing configurations and new features
  - Contains `config/` folder with JSON project configurations
  - Includes Terragrunt configuration for deployment
  
- **test/**: Test environment for validating infrastructure changes
  - Contains `config/` folder with JSON project configurations
  - Includes `pipeline.yml` for Azure DevOps CI/CD pipeline integration
  - Used for pre-production validation
  
- **prod/**: Production environment for live deployments
  - Contains `config/` folder with JSON project configurations
  - Includes Terragrunt configuration for production deployments
  - Requires stricter governance and change control

Each environment folder has:
- `env.hcl`: Environment-specific Terragrunt variables
- `project.hcl`: Project-specific configuration
- `config/`: Directory containing JSON configuration files for GCP projects
- `src/`: Directory containing Terragrunt execution files

---

## Configuration Structure

The configuration is a JSON object. Each object defines the parameters for creating and managing a GCP project, including IAM, billing, networking, service accounts, policies, and budgets.

---

## GCP Project Configuration Fields

| Field                                         | Type                    | Description                                                                                                           | Required | Default                                                            |
| --------------------------------------------- | ----------------------- | --------------------------------------------------------------------------------------------------------------------- | -------- | ------------------------------------------------------------------ |
| `deploy`                                      | Boolean                 | Indicates whether to deploy the project.                                                                              | Yes      | -                                                                  |
| `project_name`                                | String                  | Unique project ID in GCP.                                                                                             | Yes      | -                                                                  |
| `billing_account`                             | String                  | Billing account ID associated with the project.                                                                       | yes      | if `billing_account` is not provided, it can be set to 010BA9-2BB048-0F440F                                                                  |
| `labels`                                      | Map(String)             | Resource labels for organization and filtering.                                                                       | Yes      | user must provide cost-center but if not known use ${default_cost_center}, enironment_owner and lifecycle key and value.                                                                |
| `oslogin`                                     | Boolean                 | Enable OS Login for the project.                                                                                      | No      | true                                                                  |
| `deletion_policy`                             | String (optional)       | Policy for project deletion protection. Options: `"PREVENT"`, `"ABANDON"`, `"DELETE"`; default: `"PREVENT"`.          | No       | `"PREVENT"`                                                        |
| `auto_create_network`                         | Boolean (optional)      | Whether to automatically create the default network. Default: `false`.                                                | No       | `false`                                                            |
| `oslogin_admins`                              | List(String) (optional) | List of IAM identities granted OS Login admin roles.                                                                  | No       | `[]`                                                               |
| `oslogin_users`                               | List(String) (optional) | List of IAM identities granted OS Login user roles.                                                                   | No       | `[]`                                                               |
| `parent`                                      | String                  | Parent folder or organization in `folders/xxx` or `organizations/xxx` format.                                         | Yes      | choose from "728935495814"  # prj-prod-devops ,"1017170088191" # prj-nonprod-devops ,"655617541272"                                                                |
| `policy_boolean`                              | Map(Boolean) (optional) | Map of boolean org policies; set to `null` for restore.                                                               | No       | `{}`                                                               |
| `policy_list`                                 | Map(Object) (optional)  | Map of list org policies with inherit, suggested value, status, and values.                                           | No       | `{}`                                                               |
| `services`                                    | List(String) (optional) | List of APIs to enable in the project.                                                                                | No       | `[]`                                                               |
| `service_config`                              | Object (optional)       | Configuration for service APIs, e.g., disable on destroy, disable dependent services. Default disables both.          | No       | `{ disable_on_destroy = true, disable_dependent_services = true }` |
| `shared_vpc_host_config`                      | Boolean (optional)      | Configure project as a Shared VPC host. Default: `false`.                                                             | No       | `false`                                                            |
| `shared_vpc_service_config`                   | Object (optional)       | Configure project as a Shared VPC service, with attach and host project. Default: attach `false`, empty host project. | No       | `{ attach = false, host_project = "" }`                            |
| `service_accounts`                            | List(Object) (optional) | List of service accounts to create, with roles and permissions.                                                       | No       | `[]`                                                               |
| `ad_groups`                                   | List(Object) (optional) | List of Active Directory groups with assigned roles and permissions.                                                  | No       | `[]`                                                               |
| `iap_tunnel_members_list`                     | List(String) (optional) | List of users granted `iap.tunnelResourceAccessor` role.                                                              | No       | `[]`                                                               |
| `kms_encrypterdecrypter_members_list`         | List(String) (optional) | List of users granted `cryptoKeyEncrypterDecrypter` role.                                                             | No       | `[]`                                                               |
| `default_cmk_encrypterdecrypter_members_list` | List(String) (optional) | Members granted `cryptoKeyEncrypterDecrypter` role for default CMK.                                                   | No       | `[]`                                                               |
| `enable_default_global_cmk`                   | Boolean (optional)      | Whether to create the default global customer-managed encryption key (CMK). Default: `false`.                         | No       | `false`                                                            |
| `bucket_log_bucket`                           | String (optional)       | Name of the bucket for access and storage logs.                                                                       | No       | `null`                                                             |
| `workerpool_project_id`                       | String (optional)       | Project ID for CloudBuild private worker pool.                                                                        | No       | `null`                                                             |
| `location`                                    | String (optional)       | Resource location for naming and placement. Default: `"us-east4"`.                                                    | No       | `"us-east4"`                                                       |
| `default_logging_metrics_create`              | Boolean (optional)      | Create default logging metrics. Default: `true`.                                                                      | No       | `true`                                                             |
| `additional_user_defined_logging_metrics`     | List(Object) (optional) | Additional custom logging metrics.                                                                                    | No       | `[]`                                                               |
| `budget`                                      | Object (optional)       | Budget configuration including amount, threshold rules, and notification types.                                       | No       | Default example provided below.                                    |

---

## Example JSON Configuration

### 1. Minimal Configuration (Only Required Fields)

```json
{
    {
      "project_name": "prj-<dev/prod/test>-udp-<unique-name>",
      "billing_account": "010BA9-2BB048-0F440F",
      "labels": {
        "owner": "this_project_owner",
        "lifecycle": "${environment}",
        "cost-center": "${default_cost_center}"
      }
    }
}
```

---

### 2. Typical Configuration (Required + Some Optional Fields)

```json
{
  "deploy": true,
  "project_name": "prj-<dev/prod/test>-udp-<unique-name>",
  "billing_account": "010BA9-2BB048-0F440F",
  "labels": {
    "owner": "this_project_owner",
    "lifecycle": "${environment}",
    "cost-center": "${default_cost_center}"
  },
  "oslogin": false,
  "parent": "folders/9876543210",
  "auto_create_network": true,
  "oslogin_admins": ["user:admin@southwire.com"],
  "services": ["compute.googleapis.com", "storage.googleapis.com"],
  "service_accounts": [
    {
      "create": true,
      "name": "<dev/prod/test>-analytics-sa", //follow this naming convention
      "iam_roles": ["roles/viewer"],
      "raw_read_access": true
    }
  ],
  "location": "us-east4",
  "default_logging_metrics_create": false
}
```

---

### 3. Full Configuration (All Optional Fields Included)

```json
{
  "deploy": true,
  "project_name": "prj-dev-udp-rds",
  "billing_account": "010BA9-2BB048-0F440F",
  "labels": {
    "team": "data-platform",
    "cost-center": "${default_cost_center}",
    "owner": "this_project_owner",
    "lifecycle": "${environment}"
  },
  "oslogin": true,
  "deletion_policy": "PREVENT",
  "auto_create_network": false,
  "oslogin_admins": [
    "user:admin@southwire.com",
    "group:oslogin-admins@southwire.com"
  ],
  "oslogin_users": [
    "user:user1@southwire.com",
    "group:oslogin-users@southwire.com"
  ],
  "parent": "folders/1234567890",
  "policy_boolean": {
    "constraints/compute.disableSerialPortAccess": true,
    "constraints/iam.disableServiceAccountKeyCreation": false
  },
  "policy_list": {
    "constraints/iam.allowedPolicyMemberDomains": {
      "inherit_from_parent": true,
      "suggested_value": "example.com",
      "status": true,
      "values": ["example.com", "partner.com"]
    }
  },
  "services": [
    "compute.googleapis.com",
    "storage.googleapis.com",
    "cloudkms.googleapis.com"
  ],
  "service_config": {
    "disable_on_destroy": true,
    "disable_dependent_services": false
  },
  "shared_vpc_host_config": true,
  "shared_vpc_service_config": {
    "attach": true,
    "host_project": "host-project-name"
  },
  "service_accounts": [
    {
      "create": true,
      "name": "dev-data-sa",
      "iam_roles": ["roles/editor", "roles/storage.objectViewer"],
      "raw_read_access": true,
      "eds_read_access": true,
      "ods_read_access": false
    }
  ],
  "ad_groups": [
    {
      "name": "gcp-data-enginnering-team@southwire.com",
      "iam_roles": ["roles/bigquery.admin"],
      "raw_read_access": true,
      "eds_read_access": false,
      "ods_read_access": true
    }
  ],
  "iap_tunnel_members_list": ["user:iapuser@southwire.com"],
  "kms_encrypterdecrypter_members_list": ["user:kmsuser@southwire.com"],
  "default_cmk_encrypterdecrypter_members_list": [
    "group:cmk-admins@southwire.com"
  ],
  "enable_default_global_cmk": true,
  "bucket_log_bucket": "project-logs-bucket",
  "workerpool_project_id": "workerpool-project",
  "location": "europe-west1",
  "default_logging_metrics_create": true,
  "additional_user_defined_logging_metrics": [
    {
      "name": "custom-metric-1",
      "filter": "resource.type=gce_instance AND severity>=ERROR",
      "metric_descriptor": {
        "metric_kind": "GAUGE",
        "value_type": "INT64"
      }
    }
  ],
  "budget": {
    "amount": "1000",
    "threshold_rules": [0.5, 0.8, 1.0],
    "types": [
      {
        "type": "email",
        "send_notifications_to": ["your_email@southwire.com"]
      }
    ]
  }
}
```

---

## Usage

1. Create a JSON file in your environment specific config folder following the structure above.
2. Terragrunt will use this JSON file as input for the Terraform module that will create the project.
3. The Terraform module will receive the config as terraform variables which is then used for the appropriate Terraform resources to manage your project.

---

## Notes

- Ensure that all required fields are provided for each environment configuration.
- The `project_name` must be unique across GCP.
- The `project_name` must be 30 characters or less. Use this naming convention: `prj-<dev/prod/test>-udp-<unique-name> `. you must follow this naming convention for the project name.
- The 'labels' must have cost-center, environment_owner and lifecycle labels.
-  
- The `send_notifications_to` is not required for the `budget` field. if you do not provide a value for this field, the default value cloudengineering@southwire.com will be used.
- Adjust optional fields such as services, service_accounts, and labels based on your project requirements. should not be used for dev/test/prod environments.
- Be mindful of IAM roles and permissions to follow the principle of least privilege and maintain security best practices
