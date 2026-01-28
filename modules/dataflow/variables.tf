variable "dataflow_job" {
  description = "List of Dataflow job configurations."
  type = list(object({
    deploy                      = bool                                      #(Required) Whether to deploy the dataflow classic job
    name                        = string                                    #(Required) Name of the job.
    template_gcs_path           = string                                    #(Required) Path to the template in GCS.
    temp_gcs_location           = string                                    #(Required) Temporary GCS location.
    parameters                  = optional(map(string), {})                 #(Optional) Parameters for the job.
    labels                      = optional(map(string), {})                 #(Optional) Labels for the job.
    transform_name_mapping      = optional(map(string), {})                 #(Optional) Mapping for transform names.
    max_workers                 = number                                    #(Required) Maximum number of workers.
    on_delete                   = optional(string, "")                      #(Optional) Action to take on deletion.
    skip_wait_on_job_termination = optional(bool, false)                    #(Optional) Skip waiting for job termination.
    project                     = string                                    #(Required) GCP project ID.
    zone                        = string                                    #(Required) Compute zone.
    region                      = string                                    #(Required) Region for the job.
    service_account_email       = optional(string, "")                      #(Optional) Service account email.
    network                     = optional(string, "")                      #(Optional) Network to use.
    subnetwork                  = optional(string, "")                      #(Optional) Subnetwork to use.
    machine_type                = string                                    #(Required) Machine type for workers.
    kms_key_name                = optional(string, "")                      #(Optional) KMS key name for encryption.
    ip_configuration            = string                                    #(Required) IP configuration type.
    additional_experiments      = optional(list(string), [])                #(Optional) List of additional experiments.
    enable_streaming_engine     = bool                                      #(Required) Whether to enable streaming engine.
  }))
  default = []
}
