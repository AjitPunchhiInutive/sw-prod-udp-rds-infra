locals {
  # Automatically load global-level variables
  global_vars      = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  project_vars     = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  files            = fileset("${get_terragrunt_dir()}/../config/", "*.yaml")
  org-policy_objects  = [for file in local.files :
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
}
include {
path = find_in_parent_folders("root.hcl")
}

terraform {
  # source = "git::ssh://git@github.com/sw-infra-modules/dataflow?ref=v0.1.7"
  source = "../../modules/org-policy"
}

inputs = {
  org-policy = local.org-policy_objects
}
