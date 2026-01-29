locals {
  organization_id = "203589767236"
  region          = "us-east4"
  owner           = "southwire"
  utility_workspace = "folders/855215620822"
  default_labels = {
    cost-center = "3385",
    provisioner = "terraform",
    compliance  = "corporate",
    sensitivity = "restricted",
    control-level = "info",
  }

  personas = {
    prod = {
      data_scientist_persona = [],
      data_analytics_persona = [],
      data_analytics_engineer_persona = [],
      data_engineering_persona = []
    },
    nonprod = {
      data_scientist_persona = [],
      data_analytics_persona = [],
      data_analytics_engineer_persona = [],
      data_engineering_persona = []
    }
  }

  sandbox = ["roles/editor", "roles/resourcemanager.projectIamAdmin"]
}