locals {
  environment = "prod"
  environment_key = "p"
  bucket_name = "itp-terraform-tfstate"
  gcp_project = "melodic-furnace-403022"
  region      = "us-east4"
  zone        = "us-east4-a"
  global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  default_labels = merge(local.global_vars.locals.default_labels,{
    lifecycle = local.environment
  })
}