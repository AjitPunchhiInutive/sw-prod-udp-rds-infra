resource "random_id" "self" {
  for_each = { for job in var.dataflow_job : "${job.project}::${job.name}" => job if job.deploy }

  byte_length = 8
  keepers = {
    region = each.value.region
    name   = each.value.name
  }
}

data "google_storage_bucket_object" "template" {
  for_each = local.buckets

  bucket = each.value
  name   = local.object_names[each.key]
}

resource "null_resource" "template_change_trigger" {
  for_each = local.buckets

  triggers = {
    template_md5 = data.google_storage_bucket_object.template[each.key].md5hash
  }
}

resource "google_dataflow_job" "self" {
  for_each = { for job in var.dataflow_job : "${job.project}::${job.name}" => job if job.deploy }

  provider                      = google-beta
  name                          = "${each.value.name}-${random_id.self[each.key].dec}"
  template_gcs_path             = each.value.template_gcs_path
  temp_gcs_location             = each.value.temp_gcs_location
  parameters                    = each.value.parameters
  labels                        = each.value.labels
  transform_name_mapping        = each.value.transform_name_mapping
  max_workers                   = each.value.max_workers
  on_delete                     = each.value.on_delete
  skip_wait_on_job_termination  = each.value.skip_wait_on_job_termination
  project                       = each.value.project
  zone                          = each.value.zone
  region                        = each.value.region
  service_account_email         = each.value.service_account_email
  network                       = each.value.network
  subnetwork                    = each.value.subnetwork
  machine_type                  = each.value.machine_type
  kms_key_name                  = each.value.kms_key_name
  ip_configuration              = each.value.ip_configuration
  additional_experiments        = each.value.additional_experiments
  enable_streaming_engine       = each.value.enable_streaming_engine

  lifecycle {
    create_before_destroy = true

    replace_triggered_by = [
      #null_resource.template_change_trigger[each.key]
    ]
  }
}
