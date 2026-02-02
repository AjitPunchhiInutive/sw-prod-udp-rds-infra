# locals {
#   # Automatically load global-level variables
#   global_vars      = read_terragrunt_config(find_in_parent_folders("global.hcl"))
#   project_vars     = read_terragrunt_config(find_in_parent_folders("project.hcl"))
#   environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  
#   # Organization ID from global vars
#   organization_id  = local.global_vars.locals.organization_id
  
#   # Read YAML files from config directory
#   files            = fileset("${get_terragrunt_dir()}/../config/", "*.yaml")
  
#   # Parse YAML files with templating
#   parsed_configs   = [for file in local.files :
#     yamldecode(
#       templatefile(
#         "${get_terragrunt_dir()}/../config/${file}",
#         {
#           environment_key     = local.environment_vars.locals.environment_key,
#           lifecycle           = local.environment_vars.locals.environment,
#           default_cost_center = local.environment_vars.locals.default_labels.cost-center
#         }
#       )
#     )
#   ]
  
#   # Merge all YAML configs into a single object
#   merged_config = merge(local.parsed_configs...)
  
#   # Extract parent folders
#   parent_folders = lookup(local.merged_config, "parent_folders", {})
  
#   # Extract sub folders
#   sub_folders = lookup(local.merged_config, "sub_folders", {})

#   # Extract nested folders
#   nested_folders = lookup(local.merged_config, "nested_folders", {})
# }

# include {
#   path = find_in_parent_folders("root.hcl")
# }

# terraform {
#   source = "../../modules/folders"
# }

# # IMPORTANT: Uncomment this to pass data to Terraform
# inputs = {
#   organization_id = local.env_vars.locals.organization_id
#   parent_folders  = local.env_vars.locals.parent_folders_id
#   sub_folders     = local.env_vars.locals.sub_folders_id
#   nested_folders  = local.env_vars.locals.nested_folders.id
# }

locals {
  # Automatically load global-level variables
  global_vars      = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  project_vars     = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  files            = fileset("${get_terragrunt_dir()}/../config/", "*.yaml")
  project_objects  = [for file in local.files :
    yamldecode(
      templatefile(
        "${get_terragrunt_dir()}/../config/${file}",
        {
          environment_key = local.environment_vars.locals.environment_key,
          lifecycle = local.environment_vars.locals.environment,
          default_cost_center = local.environment_vars.locals.default_labels.cost-center
        }
      )
    )
  ]
  # files            = fileset("${get_terragrunt_dir()}/../config/", "*.json")
  # project_objects  = [for file in local.files :
  #   jsondecode(
  #     templatefile(
  #       "${get_terragrunt_dir()}/../config/${file}",
  #       {
  #         environment_key = local.environment_vars.locals.environment_key,
  #         lifecycle = local.environment_vars.locals.environment,
  #         default_cost_center = local.environment_vars.locals.default_labels.cost-center
  #       }
  #     )
  #   )
  # ]
}

include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  # source = "git::ssh://git@github.com/sw-infra-modules/dataflow?ref=v0.1.7"
  source = "../../modules/folders"
}

inputs = {
  organization_id = "203589767236"  # Add this line
  #folders_objects = local.folders_objects
}