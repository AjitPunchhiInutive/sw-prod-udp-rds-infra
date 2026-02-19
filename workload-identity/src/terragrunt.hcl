locals {
  # Automatically load global-level variables
  global_vars      = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  project_vars     = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  
  # Find all YAML files in config directory
  files = fileset("${get_terragrunt_dir()}/../config/", "*.yaml")
  
  # Parse each YAML file with templating
  wif_objects = [for file in local.files :
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
  
  # Merge all YAML configs into a single map
  # This assumes each YAML has the same structure
  merged_config = length(local.parsed_yamls) > 0 ? merge(local.parsed_yamls...) : {}
  
  # Extract service accounts from merged config
  service_accounts = lookup(local.merged_config, "service_accounts", {})
}

include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../modules/service-account"
}

inputs = {
github_workload-identity_factory = local.wif.objects
}