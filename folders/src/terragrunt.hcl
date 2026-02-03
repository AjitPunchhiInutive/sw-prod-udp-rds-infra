locals {
  # Automatically load global-level variables
  global_vars      = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  project_vars     = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Read all YAML files from the config directory
  files           = fileset("${get_terragrunt_dir()}/../config/", "*.yaml")

  # Parse each YAML file into an object
  parsed_configs  = [for file in local.files :
    yamldecode(
      templatefile(
        "${get_terragrunt_dir()}/../config/${file}",
        {
          environment_key     = local.environment_vars.locals.environment_key
          lifecycle           = local.environment_vars.locals.environment
          default_cost_center = local.environment_vars.locals.default_labels.cost-center
        }
      )
    )
  ]

  # Extract the first (and expected only) config object
  folder_config   = local.parsed_configs[0]

  # Extract individual fields from the parsed YAML
  organization_id = local.folder_config.organization_id
  deploy          = local.folder_config.deploy
  parent_folders  = local.folder_config.parent_folders
  sub_folders     = local.folder_config.sub_folders
  nested_folders  = local.folder_config.nested_folders
}

include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../modules/folders"
}

# Only deploy if deploy flag is true in YAML
inputs = {
  organization_id = local.organization_id
  parent_folders  = local.parent_folders
  sub_folders     = local.sub_folders
  nested_folders  = local.nested_folders
}