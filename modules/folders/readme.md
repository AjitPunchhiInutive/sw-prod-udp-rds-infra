# Google Cloud Folder Hierarchy Terraform Module

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Features](#features)
4. [Prerequisites](#prerequisites)
5. [Inputs](#inputs)
6. [Outputs](#outputs)
7. [Usage Examples](#usage-examples)
   - [Basic Terraform Example](#basic-terraform-example)
   - [Advanced Terraform Example](#advanced-terraform-example)
   - [Terragrunt Examples](#terragrunt-examples)

## Overview

This Terraform module creates a hierarchical folder structure within a Google Cloud Platform (GCP) organization. It enables you to create and manage parent folders and sub-folders to organize your GCP resources in a structured and scalable way.

The module is designed to work seamlessly with Terragrunt for managing multiple environments and configurations.

## Architecture

```
GCP Organization (123456789012)
├── Parent Folder: Production
│   ├── Sub-Folder: Backend Services
│   ├── Sub-Folder: Frontend Services
│   └── Sub-Folder: Data Services
├── Parent Folder: Staging  
│   ├── Sub-Folder: Backend Services
│   └── Sub-Folder: Frontend Services
├── Parent Folder: Development
│   ├── Sub-Folder: Experiments
│   └── Sub-Folder: Sandbox
└── Parent Folder: Shared Services
    ├── Sub-Folder: Networking
    ├── Sub-Folder: Security
    └── Sub-Folder: Monitoring
```

## Features

- ✅ Creates parent folders directly under a GCP organization
- ✅ Creates sub-folders as children of parent folders
- ✅ Comprehensive input validation for data integrity
- ✅ Outputs folder IDs and names for reference by other modules
- ✅ Terragrunt compatible with DRY configurations
- ✅ Support for complex folder hierarchies
- ✅ Built-in dependency management between folder levels

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
  "production" = "folders/123456789"
  "staging"    = "folders/234567890" 
  "development"= "folders/345678901"
}

# sub_folder_ids  
{
  "prod-backend"  = "folders/456789012"
  "prod-frontend" = "folders/567890123"
  "staging-api"   = "folders/678901234"
}
```

## Usage Examples

### Basic Terraform Example

```hcl
module "folder_hierarchy" {
  source = "path/to/folder-hierarchy-module"

  folders_objects = {
    organization_id = "123456789012"
    
    parent_folders = {
      "production" = {
        display_name = "Production Environment"
      }
      "development" = {
        display_name = "Development Environment"  
      }
    }
    
    sub_folders = {
      "prod-apps" = {
        display_name  = "Production Applications"
        parent_folder = "production"
      }
      "dev-sandbox" = {
        display_name  = "Development Sandbox"
        parent_folder = "development"
      }
    }
  }
}

# Reference the outputs
output "production_folder_id" {
  value = module.folder_hierarchy.parent_folder_ids["production"]
}

output "all_sub_folders" {
  value = module.folder_hierarchy.sub_folder_ids
}
```

### Advanced Terraform Example

```hcl
locals {
  organization_id = "123456789012"
  
  # Define environments
  environments = ["production", "staging", "development"]
  
  # Define business units
  business_units = {
    "bu-ecommerce" = "E-commerce Platform"
    "bu-analytics" = "Data Analytics" 
    "bu-mobile"    = "Mobile Applications"
  }
  
  # Generate parent folders dynamically
  parent_folders = merge(
    # Environment folders
    {
      for env in local.environments :
      env => {
        display_name = title(env)
      }
    },
    # Business unit folders  
    {
      for key, name in local.business_units :
      key => {
        display_name = name
      }
    },
    # Shared services
    {
      "shared-services" = {
        display_name = "Shared Services"
      }
    }
  )
  
  # Generate sub-folders dynamically
  sub_folders = merge(
    # Environment sub-folders
    {
      for env in local.environments :
      "${env}-backend" => {
        display_name  = "Backend Services"
        parent_folder = env
      }
    },
    {
      for env in local.environments :
      "${env}-frontend" => {
        display_name  = "Frontend Services" 
        parent_folder = env
      }
    },
    # Business unit sub-folders
    {
      for key, name in local.business_units :
      "${key}-prod" => {
        display_name  = "Production"
        parent_folder = key
      }
    },
    {
      for key, name in local.business_units :
      "${key}-dev" => {
        display_name  = "Development"
        parent_folder = key
      }
    },
    # Shared services sub-folders
    {
      "networking" = {
        display_name  = "Networking & Connectivity"
        parent_folder = "shared-services"
      }
      "security" = {
        display_name  = "Security & Compliance"
        parent_folder = "shared-services"  
      }
      "monitoring" = {
        display_name  = "Monitoring & Observability"
        parent_folder = "shared-services"
      }
    }
  )
}

module "folder_hierarchy" {
  source = "path/to/folder-hierarchy-module"

  folders_objects = {
    organization_id = local.organization_id
    parent_folders  = local.parent_folders
    sub_folders     = local.sub_folders
  }
}
```

#### Root `terragrunt.hcl`

```hcl
# terragrunt/terragrunt.hcl

# Configure remote state
remote_state {
  backend = "gcs"
  config = {
    bucket  = "your-terraform-state-bucket"
    prefix  = "folder-hierarchy/${path_relative_to_include()}"
    project = "your-project-id"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Generate provider configuration
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = "your-project-id"
  region  = "us-central1"
}
EOF
}

# Common inputs for all environments
inputs = {
  organization_id = "123456789012"
}
```

#### Production Environment - `environments/production/folders/terragrunt.hcl`

```hcl
# environments/production/folders/terragrunt.hcl

include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/folder-hierarchy"
}

inputs = {
  folders_objects = {
    organization_id = "123456789012"
    
    parent_folders = {
      "prod-workloads" = {
        display_name = "Production Workloads"
      }
      "prod-shared" = {
        display_name = "Production Shared Services"
      }
    }
    
    sub_folders = {
      "prod-backend-services" = {
        display_name  = "Backend Services"
        parent_folder = "prod-workloads"
      }
      "prod-frontend-apps" = {
        display_name  = "Frontend Applications"
        parent_folder = "prod-workloads"
      }
      "prod-data-platform" = {
        display_name  = "Data Platform"
        parent_folder = "prod-workloads"
      }
      "prod-networking" = {
        display_name  = "Networking"
        parent_folder = "prod-shared"
      }
      "prod-security" = {
        display_name  = "Security & Compliance"
        parent_folder = "prod-shared"
      }
      "prod-monitoring" = {
        display_name  = "Monitoring & Logging"
        parent_folder = "prod-shared"
      }
    }
  }
}
```

#### Staging Environment - `environments/staging/folders/terragrunt.hcl`

```hcl
# environments/staging/folders/terragrunt.hcl

include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/folder-hierarchy"
}

inputs = {
  folders_objects = {
    organization_id = "123456789012"
    
    parent_folders = {
      "staging-workloads" = {
        display_name = "Staging Workloads"
      }
      "staging-shared" = {
        display_name = "Staging Shared Services"
      }
    }
    
    sub_folders = {
      "staging-backend" = {
        display_name  = "Backend Services"
        parent_folder = "staging-workloads"
      }
      "staging-frontend" = {
        display_name  = "Frontend Applications"
        parent_folder = "staging-workloads"
      }
      "staging-data" = {
        display_name  = "Data Services"
        parent_folder = "staging-workloads"
      }
      "staging-networking" = {
        display_name  = "Networking"
        parent_folder = "staging-shared"
      }
      "staging-monitoring" = {
        display_name  = "Monitoring"
        parent_folder = "staging-shared"
      }
    }
  }
}
```

#### Development Environment - `environments/development/folders/terragrunt.hcl`

```hcl
# environments/development/folders/terragrunt.hcl

include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/folder-hierarchy"
}

inputs = {
  folders_objects = {
    organization_id = "123456789012"
    
    parent_folders = {
      "dev-projects" = {
        display_name = "Development Projects"
      }
      "dev-sandbox" = {
        display_name = "Developer Sandbox"
      }
    }
    
    sub_folders = {
      "dev-microservices" = {
        display_name  = "Microservices Development"
        parent_folder = "dev-projects"
      }
      "dev-web-apps" = {
        display_name  = "Web Applications"
        parent_folder = "dev-projects"
      }
      "dev-experiments" = {
        display_name  = "Experiments & POCs"
        parent_folder = "dev-sandbox"
      }
      "dev-learning" = {
        display_name  = "Learning & Training"
        parent_folder = "dev-sandbox"
      }
    }
  }
}
```

#### Multi-Environment Terragrunt with DRY Configuration

```hcl
# environments/terragrunt.hcl (common configuration)

locals {
  # Environment-specific configuration
  environment_configs = {
    production = {
      parent_folders = {
        "prod-critical" = { display_name = "Production Critical Systems" }
        "prod-standard" = { display_name = "Production Standard Systems" }
      }
      sub_folders = {
        "prod-databases" = {
          display_name  = "Production Databases"
          parent_folder = "prod-critical"
        }
        "prod-apis" = {
          display_name  = "Production APIs"  
          parent_folder = "prod-critical"
        }
        "prod-batch" = {
          display_name  = "Batch Processing"
          parent_folder = "prod-standard" 
        }
      }
    }
    
    staging = {
      parent_folders = {
        "staging-testing" = { display_name = "Staging & Testing" }
      }
      sub_folders = {
        "staging-integration" = {
          display_name  = "Integration Testing"
          parent_folder = "staging-testing"
        }
        "staging-performance" = {
          display_name  = "Performance Testing"
          parent_folder = "staging-testing"
        }
      }
    }
    
    development = {
      parent_folders = {
        "dev-active" = { display_name = "Active Development" }
        "dev-archive" = { display_name = "Development Archive" }
      }
      sub_folders = {
        "dev-feature-branches" = {
          display_name  = "Feature Development"
          parent_folder = "dev-active"
        }
        "dev-completed" = {
          display_name  = "Completed Features"
          parent_folder = "dev-archive"
        }
      }
    }
  }
  
  # Extract environment from path
  environment = reverse(split("/", get_terragrunt_dir()))[1]
  
  # Get configuration for current environment
  env_config = local.environment_configs[local.environment]
}

include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules/folder-hierarchy"
}

inputs = {
  folders_objects = {
    organization_id = "123456789012"
    parent_folders  = local.env_config.parent_folders
    sub_folders     = local.env_config.sub_folders
  }
}
```