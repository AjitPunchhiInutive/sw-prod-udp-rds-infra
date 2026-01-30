# GCP Folder Structure Terraform Module

A Terraform module for creating and managing hierarchical folder structures in Google Cloud Platform (GCP). This module supports up to three levels of folder nesting: parent folders (under organization), sub-folders, and nested folders.


## ✨ Features

- ✅ **Three-level folder hierarchy** - Create parent folders, sub-folders, and nested folders
- ✅ **Flexible structure** - Define any organizational structure using simple map objects
- ✅ **Type-safe inputs** - Full validation on organization ID and folder references
- ✅ **Comprehensive outputs** - Access folder IDs, names, and detailed metadata
- ✅ **Dependency management** - Automatic handling of folder creation order
- ✅ **Easy to extend** - Simple structure for adding IAM policies or additional configurations

## 🔧 Prerequisites

- **Terraform** >= 1.0
- **Google Cloud Provider** >= 5.0
- **GCP Organization** with appropriate permissions
- **Service Account** with the following roles:
  - `roles/resourcemanager.folderAdmin` (Organization level)
  - `roles/resourcemanager.organizationViewer` (Organization level)

## 🏗️ Architecture

```
Organization (Root)
├── Parent Folder 1
│   ├── Sub-Folder 1.1
│   │   ├── Nested Folder 1.1.1
│   │   └── Nested Folder 1.1.2
│   └── Sub-Folder 1.2
├── Parent Folder 2
│   └── Sub-Folder 2.1
│       └── Nested Folder 2.1.1
└── Parent Folder 3
```

## 📦 Module Structure

```
.
├── main.tf          # Main resource definitions
├── variables.tf     # Input variable definitions
├── outputs.tf       # Output definitions
├── locals.tf        # Local values and computed data
├── README.md        # This file

```

## 🚀 Usage

### Basic Example

```hcl
module "folders" {
  source = "github.com/your-org/terraform-gcp-folder-structure"

  organization_id = "123456789012"

  parent_folders = {
    engineering = {
      display_name = "Engineering"
    }
    data = {
      display_name = "Data-Platform"
    }
  }

  sub_folders = {
    eng_dev = {
      display_name  = "Development"
      parent_folder = "engineering"
    }
    eng_prod = {
      display_name  = "Production"
      parent_folder = "engineering"
    }
  }

  nested_folders = {
    eng_dev_backend = {
      display_name  = "Backend-Services"
      parent_folder = "eng_dev"
    }
    eng_dev_frontend = {
      display_name  = "Frontend-Apps"
      parent_folder = "eng_dev"
    }
  }
}
```

### Using with Terragrunt and YAML

```hcl
# terragrunt.hcl
locals {
  folder_config = yamldecode(file("folders.yaml"))
}

inputs = {
  organization_id = local.folder_config.organization_id
  parent_folders  = local.folder_config.parent_folders
  sub_folders     = local.folder_config.sub_folders
  nested_folders  = local.folder_config.nested_folders
}
```

```yaml
# folders.yaml
organization_id: "1111111111"

parent_folders:
  engineering:
    display_name: "Engineering"
  data:
    display_name: "Data-Platform"

sub_folders:
  eng_dev:
    display_name: "Development"
    parent_folder: "engineering"
  eng_prod:
    display_name: "Production"
    parent_folder: "engineering"

nested_folders:
  eng_dev_backend:
    display_name: "Backend-Services"
    parent_folder: "eng_dev"
```

## 📚 Examples

### Simple Two-Level Structure

```hcl
module "simple_folders" {
  source = "./modules/gcp-folders"

  organization_id = "123456789012"

  parent_folders = {
    company = {
      display_name = "MyCompany"
    }
  }

  sub_folders = {
    dev = {
      display_name  = "Development"
      parent_folder = "company"
    }
    prod = {
      display_name  = "Production"
      parent_folder = "company"
    }
  }
}
```

**Creates:**
```
Organization
└── MyCompany
    ├── Development
    └── Production
```

### Complex Multi-Environment Structure

```hcl
module "complex_folders" {
  source = "./modules/gcp-folders"

  organization_id = "123456789012"

  parent_folders = {
    platform = {
      display_name = "Platform"
    }
    shared = {
      display_name = "Shared-Services"
    }
  }

  sub_folders = {
    # Platform subfolders
    platform_dev = {
      display_name  = "Development"
      parent_folder = "platform"
    }
    platform_staging = {
      display_name  = "Staging"
      parent_folder = "platform"
    }
    platform_prod = {
      display_name  = "Production"
      parent_folder = "platform"
    }
    
    # Shared services subfolders
    shared_networking = {
      display_name  = "Networking"
      parent_folder = "shared"
    }
    shared_security = {
      display_name  = "Security"
      parent_folder = "shared"
    }
  }

  nested_folders = {
    # Development nested folders
    dev_app1 = {
      display_name  = "Application-1"
      parent_folder = "platform_dev"
    }
    dev_app2 = {
      display_name  = "Application-2"
      parent_folder = "platform_dev"
    }
    
    # Production nested folders
    prod_app1 = {
      display_name  = "Application-1"
      parent_folder = "platform_prod"
    }
    prod_app2 = {
      display_name  = "Application-2"
      parent_folder = "platform_prod"
    }
    
    # Networking nested folders
    net_vpc = {
      display_name  = "VPC-Networks"
      parent_folder = "shared_networking"
    }
    net_firewall = {
      display_name  = "Firewall-Rules"
      parent_folder = "shared_networking"
    }
  }
}
```

**Creates:**
```
Organization
├── Platform
│   ├── Development
│   │   ├── Application-1
│   │   └── Application-2
│   ├── Staging
│   └── Production
│       ├── Application-1
│       └── Application-2
└── Shared-Services
    ├── Networking
    │   ├── VPC-Networks
    │   └── Firewall-Rules
    └── Security
```

## 📥 Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| organization_id | GCP Organization ID (numeric) | `string` | - | yes |
| parent_folders | Parent folders to create under organization | `map(object({display_name=string}))` | `{}` | no |
| sub_folders | Sub-folders to create under parent folders | `map(object({display_name=string, parent_folder=string}))` | `{}` | no |
| nested_folders | Nested folders to create under sub-folders | `map(object({display_name=string, parent_folder=string}))` | `{}` | no |

### Variable Details

#### `organization_id`
- **Type:** `string`
- **Validation:** Must be numeric
- **Example:** `"123456789012"`

#### `parent_folders`
- **Type:** Map of objects
- **Keys:** Unique identifier for each parent folder (used as reference in sub_folders)
- **Values:**
  - `display_name` (required) - Display name shown in GCP Console

#### `sub_folders`
- **Type:** Map of objects
- **Keys:** Unique identifier for each sub-folder (used as reference in nested_folders)
- **Values:**
  - `display_name` (required) - Display name shown in GCP Console
  - `parent_folder` (required) - Key reference to parent folder

#### `nested_folders`
- **Type:** Map of objects
- **Keys:** Unique identifier for each nested folder
- **Values:**
  - `display_name` (required) - Display name shown in GCP Console
  - `parent_folder` (required) - Key reference to sub-folder

## 📤 Outputs

| Name | Description |
|------|-------------|
| parent_folder_ids | Map of parent folder keys to GCP folder resource names |
| sub_folder_ids | Map of sub-folder keys to GCP folder resource names |
| nested_folders_ids | Map of nested folder keys to GCP folder resource names |
| all_folder_ids | Combined map of all folder keys to folder IDs |
| folder_details | Detailed information for all folders including display name, parent, and type |

### Output Examples

```hcl
# Access specific folder ID
output "engineering_folder_id" {
  value = module.folders.parent_folder_ids["engineering"]
}

# Access all folder details
output "all_folders" {
  value = module.folders.folder_details
}

# Example output structure:
# {
#   "engineering" = {
#     "id" = "folders/123456789"
#     "display_name" = "Engineering"
#     "parent" = "organizations/123456789012"
#     "type" = "parent"
#   }
#   "eng_dev" = {
#     "id" = "folders/987654321"
#     "display_name" = "Development"
#     "parent" = "folders/123456789"
#     "type" = "sub"
#   }
# }
```

## 🌳 Folder Hierarchy

This module creates a three-level folder hierarchy:

### Level 1: Parent Folders
- Direct children of the GCP Organization
- Created first
- Can be referenced by sub-folders

### Level 2: Sub-Folders
- Children of parent folders
- Depend on parent folder creation
- Can be referenced by nested folders

### Level 3: Nested Folders
- Children of sub-folders
- Depend on sub-folder creation
- Third and final level of nesting

### Dependency Chain

```
Organization
    ↓
Parent Folders (Level 1)
    ↓
Sub-Folders (Level 2)
    ↓
Nested Folders (Level 3)
```



## 🔒 Best Practices

### 1. Naming Conventions

```hcl
# ✅ Good: Use consistent, descriptive keys
parent_folders = {
  data_platform = { display_name = "Data-Platform" }
}

```

### 2. Logical Hierarchy

```hcl
# ✅ Good: Organize by environment or team
parent_folders = { environments = { display_name = "Environments" } }
sub_folders = {
  env_dev = { display_name = "Development", parent_folder = "environments" }
  env_prod = { display_name = "Production", parent_folder = "environments" }
}


### 3. Use Outputs for Downstream Resources

```hcl
# Use folder IDs in project creation
resource "google_project" "app" {
  name       = "my-app"
  project_id = "my-app-dev"
  folder_id  = module.folders.sub_folder_ids["eng_dev"]
}
```

### 4. Document Your Structure

Always include a comment block showing the intended hierarchy:

```hcl
# Folder Structure:
# Organization
# └── Platform
#     ├── Development
#     │   ├── App1
#     │   └── App2
#     └── Production
#         ├── App1
#         └── App2

module "folders" {
  source = "./modules/gcp-folders"
  # ... configuration
}
```

### 6. Permission Management

Grant minimum required permissions:

```bash
# Organization-level permissions for service account
gcloud organizations add-iam-policy-binding ${ORG_ID} \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/resourcemanager.folderAdmin"
```