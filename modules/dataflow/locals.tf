
locals {
  template_gcs_paths = { for name, path in var.dataflow_job : name => path.template_gcs_path if path.deploy }
  buckets            = { for name, gcs_path in local.template_gcs_paths : name => regex("gs://([^/]+)", gcs_path)[0] }
  object_names       = { for name, gcs_path in local.template_gcs_paths : name => regex("gs://[^/]+/(.+)", gcs_path)[0] }
}
