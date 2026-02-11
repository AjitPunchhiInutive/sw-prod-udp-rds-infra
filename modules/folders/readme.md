# Google Cloud Folder Hierarchy Terraform Module

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Features](#features)
4. [Prerequisites](#prerequisites)
5. [Inputs](#inputs)
6. [Outputs](#outputs)
7. [Usage Examples](#usage-examples)
   - [Basic Configuration with Parent Folder](#basic-configuration-with-parent-folder)
   - [Typical Configuration with Sub Folder under Parent Folder](#typical-configuration-with-sub-folder-under-parent-folder)

## Overview

This Terraform module creates a hierarchical folder structure within a Google Cloud Platform (GCP) organization. It enables you to create and manage parent folders and sub-folders to organize your GCP resources in a structured and scalable way.

The module is designed to work seamlessly with Terragrunt for managing multiple environments and configurations.

## Architecture

```
GCP Organization (111111111111)
├── Parent Folder: sw-unified-data-platform
│   ├── Sub-Folder: sw-udp-production
│   ├── Sub-Folder: sw-udp-non-prod
│   └── Sub-Folder: sw-udp-sandbox
```

## Features

- ✅ Creates parent folders directly under a GCP organization
- ✅ Creates sub-folders as children of parent folders
- ✅ Comprehensive input validation for data integrity
- ✅ Outputs folder IDs and names for reference by other modules
- ✅ Terragrunt compatible with DRY configurations

## Prerequisites

### Required APIs
- Cloud Resource Manager API must be enabled

### Required Permissions
The service account or user needs the following IAM roles:
- `roles/resourcemanager.folderCreator` (at organization level)
- `roles/resourcemanager.folderViewer` (at organization level)


## Inputs

| Name | Description | Type | Default | Required | Validation |
|------|-------------|------|---------|:--------:|------------|
| `folders_objects` | Configuration object for organization and folder hierarchy | `object` | See structure below | ✅ | Multiple validations applied |

### `folders_objects` Structure

```hcl
variable "folders_objects" {
  description = "Configuration for organization and folder hierarchy"
  
  type = object({
    organization_id = string                    # GCP Organization ID (numeric, 6+ digits)
    
    parent_folders = map(object({              # Direct children of organization
      display_name = string                    # Human-readable folder name
    }))
    
    sub_folders = map(object({                 # Children of parent folders  
      display_name  = string                   # Human-readable folder name
      parent_folder = string                   # Key reference to parent_folders map
    }))
  })
}
```

### Input Validation Rules

1. **Organization ID**: Must be non-empty and contain at least 6 numeric characters
2. **Parent Folder References**: Each `sub_folders.parent_folder` must reference a valid key in `parent_folders`
3. **Display Names**: Must be non-empty strings

### Default Values

```hcl
default = {
  organization_id = ""
  parent_folders  = {}
  sub_folders     = {}
}
```

## Outputs

| Name | Description | Type |
|------|-------------|------|
| `parent_folder_ids` | Map of parent folder keys to Google Cloud folder IDs | `map(string)` |
| `sub_folder_ids` | Map of sub-folder keys to Google Cloud folder IDs | `map(string)` |

### Output Examples

```hcl
# parent_folder_ids
{
  "sw-unified-data-platform"        = "folders/123456789"
}

# sub_folder_ids  
{
  "sw-udp-production"  = "folders/111111111"
  "sw-udp-non-prod"    = "folders/111111111"
  "sw-udp-sandbox"     = "folders/111111111"
}
```

## Usage Examples

### Basic Configuration with Parent Folder

```hcl
deploy: true
organization_id: "203589767236"

parent_folders:
  sw-unified-data-platform:
      display_name: "sw-unified-data-platform"
```

### Typical Configuration with Sub Folder under Parent Folder

```hcl
deploy: true
organization_id: "203589767236"
parent_folders:
  sw-unified-data-platform:
      display_name: "sw-unified-data-platform"
sub_folders:
  sw-udp-production:
    display_name: "sw-udp-production"
    parent_folder: "sw-unified-data-platform" 
  sw-udp-non-prod:
    display_name: "sw-udp-non-prod"
    parent_folder: "sw-unified-data-platform"
  sw-udp-sandbox:
    display_name: "sw-udp-sandbox"
    parent_folder: "sw-unified-data-platform"
```

#### Root `terragrunt.hcl`
```hcl

  folders_objects = merge([
    for file in local.files :
    yamldecode(
      templatefile(
        "${get_terragrunt_dir()}/../config/${file}",
        {
          environment_key     = local.environment_vars.locals.environment_key
          lifecycle           = local.environment_vars.locals.environment
          default_cost_center = local.environment_vars.locals.default_labels["cost-center"]
        }
      )
    )
  ]...)


include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../modules/folders"
}

inputs = {
  folders_objects = local.folders_objects
}
```