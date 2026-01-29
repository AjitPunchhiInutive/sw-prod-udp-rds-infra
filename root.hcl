locals {
  # Load environment-specific variables if available, otherwise use defaults
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
  default_labels = local.environment_vars.default_labels
}

# Use the variables defined in the environment-specific terragrunt.hcl or defaults
generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "gcs" {
    bucket     = "${local.environment_vars.bucket_name}"
    prefix     = "sw-infra-tfstate/${path_relative_to_include()}/state"
 }
}
EOF
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = ">= 1.6.2"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
  }

provider "google" {

  project                 = "${local.environment_vars.gcp_project}"
  region                  = "${local.environment_vars.region}"
  zone                    = "${local.environment_vars.zone}"
  default_labels = {
    cost-center   = "${local.environment_vars.default_labels.cost-center}",
    provisioner   = "${local.environment_vars.default_labels.provisioner}",
    compliance    = "${local.environment_vars.default_labels.compliance}",
    sensitivity   = "${local.environment_vars.default_labels.sensitivity}",
    control-level = "${local.environment_vars.default_labels.control-level}",
    lifecycle     = "${local.environment_vars.default_labels.lifecycle}"
  }
}
provider "google-beta" {
  project                 = "${local.environment_vars.gcp_project}"
  region                  = "${local.environment_vars.region}"
  zone                    = "${local.environment_vars.zone}"
  default_labels = {
    cost-center   = "${local.environment_vars.default_labels.cost-center}",
    provisioner   = "${local.environment_vars.default_labels.provisioner}",
    compliance    = "${local.environment_vars.default_labels.compliance}",
    sensitivity   = "${local.environment_vars.default_labels.sensitivity}",
    control-level = "${local.environment_vars.default_labels.control-level}",
    lifecycle     = "${local.environment_vars.default_labels.lifecycle}"
  }
}
EOF
}