resource "google_project" "self" {
    for_each            = local.project_objects
    org_id              = each.value.parent_type == "organizations" ? each.value.parent_type : null
    folder_id           = each.value.parent_type == "folders" ? each.value.parent_id : null
    project_id          = lower(each.value.project_name)
    name                = each.value.project_name
    billing_account     = each.value.billing_account
    auto_create_network = each.value.auto_create_network
    deletion_policy     = each.value.deletion_policy
    labels              = merge(each.value.labels, {date_created = formatdate("MM-DD-YYYY", timestamp())})
    lifecycle {
      ignore_changes = [ labels["date_created"] ]
    }
}

resource "google_project_service" "self" {
    for_each                   = {for v in local.project_services: v.key => v}
    project                    = google_project.self[each.value.project_name].project_id
    service                    = each.value.service
    disable_on_destroy         = each.value.service_config.disable_on_destroy
    disable_dependent_services = each.value.service_config.disable_dependent_services
    depends_on                 = [null_resource.self ]
}

resource "google_project_service_identity" "self" {
    for_each   = {for v in local.project_kms_supported_serviceagents: v.key => v}
    provider   = google-beta
    project    = google_project.self[each.value.project_name].project_id
    service    = each.value.service
    depends_on = [google_project_service.self]
}

# module "project_logging_metrics" {
#     for_each                                = local.project_objects
#     source                                  = "../../logging-metrics"
#     project_id                              = google_project.self[each.value.project_name].project_id
#     default_logging_metrics_create          = each.value.default_logging_metrics_create
#     additional_user_defined_logging_metrics = each.value.additional_user_defined_logging_metrics
#     depends_on                              = [google_project_service.self]
# }

# module "project_default_customer_managed_keyring" {
#     for_each                       = local.project_objects
#     source                         = "../../customer-managed-key"
#     project_id                     = google_project.self[each.value.project_name].project_id
#     project_number                 = google_project.self[each.value.project_name].number
#     default_region                 = each.value.location
#     enable_default_global_cmk      = each.value.enable_default_global_cmk
#     cmk_encrypterdecrypter_members = each.value.default_cmk_encrypterdecrypter_members_list
#     labels                         = each.value.labels
#     depends_on                     = [google_project_service_identity.self]   
# }

resource "google_project_organization_policy" "self" {
    for_each   = {for v in local.project_policies_boolean: v.key => v}
    project    = google_project.self[each.value.project_name].project_id
    constraint = each.value.constraint_key

    dynamic "boolean_policy" {
        for_each = each.value.constraint_value == null ? [] : [each.value.constraint_value]
        iterator = policy
        content {
            enforced = policy.value
        }
    }

    dynamic "restore_policy" {
        for_each = each.value.constraint_value == null ? [""] : []
        content {
            default = true
        }
    }
}

resource "google_project_organization_policy" "self_list" {
    for_each   = {for v in local.project_policy_list: v.key => v}
    project    = google_project.self[each.value.project_name].project_id
    constraint = each.value.constraint_key

    dynamic "list_policy" {
        for_each = each.value.constraint_value.status == null ? [] : [each.value.constraint_value]
        iterator = policy
        content {
            inherit_from_parent = policy.value.inherit_from_parent
            suggested_value     = policy.value.suggested_value
            dynamic "allow" {
                for_each = policy.value.status ? [""] : []
                content {
                    values = (
                        try(length(policy.value.values) > 0, false)
                        ? policy.value.values
                        : null
                    )
                    all = (
                        try(length(policy.value.values) > 0, false)
                        ? null
                        : true
                    )
                }
            }
            dynamic "deny" {
                for_each = policy.value.status ? [] : [""]
                content {
                    values = (
                        try(length(policy.value.values) > 0, false)
                        ? policy.value.values
                        : null
                    )
                    all = (
                        try(length(policy.value.values) > 0, false)
                        ? null
                        : true
                    )
                }
            }
        }
    }

    dynamic "restore_policy" {
        for_each = each.value.constraint_value.status == null ? [true] : []
        content {
            default = true
        }
    }
}

resource "google_compute_shared_vpc_host_project" "self" {
  for_each   = {for k,v in local.project_objects: k => v if v.shared_vpc_host_config}    
  project    = google_project.self[each.value.project_name].project_id
  depends_on = [google_project_service.self]
}

resource "null_resource" "self" {
  depends_on = [google_project_organization_policy.self_list]

  provisioner "local-exec" {
    command = "sleep 3"  # Sleep for 3 seconds
  }
}

resource "google_compute_shared_vpc_service_project" "self" {
  for_each        = {for k,v in local.project_objects: k => v if v.shared_vpc_service_config.attach}
  host_project    = each.value.shared_vpc_service_config.host_project
  service_project = google_project.self[each.value.project_name].project_id
  depends_on      = [null_resource.self]
}

##### IAP
resource "google_project_iam_member" "iap_member" {
  for_each = {for v in local.iap_tunnel_members_list: v.key => v}
  project  = google_project.self[each.value.project_name].project_id
  role     = "roles/iap.tunnelResourceAccessor"
  member   = each.value.member
}

#### KMS
resource "google_project_iam_member" "kms_encrypterdecrypter_member" {
  for_each = {for v in local.kms_encrypterdecrypter_members_list: v.key => v}
  project  = google_project.self[each.value.project_name].project_id
  role     = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member   = each.value.member
}

#CloudBuild worker pool user IAM
resource "google_project_iam_member" "cb_sa_project_permission" {
    for_each   = {for p in local.project_objects: p.workerpool_project_id => p if p.workerpool_project_id != null}
    project    = each.value.workerpool_project_id
    role       = "roles/cloudbuild.workerPoolUser"
    member     = "serviceAccount:${google_project.self[each.value.project_name].number}@cloudbuild.gserviceaccount.com"
    depends_on = [google_project_service_identity.self]
}

resource "google_service_account" "self" {
    for_each     = {for v in local.service_accounts: v.key => v if v.create}
    project      = google_project.self[each.value.project_name].project_id
    account_id   = each.value.name
    display_name = "Service account created from project module"
}

resource "google_project_iam_member" "sa" {
    for_each   = {for v in local.sa_iam_roles: v.key => v}
    project    = google_project.self[each.value.project_name].project_id
    role       = each.value.role
    member     = try("serviceAccount:${google_service_account.self[each.value.sa_key].email}", "serviceAccount:${each.value.name}")
    depends_on = [google_service_account.self]
    lifecycle {
    precondition {
      condition = data.google_iam_role.self[each.key].name != null
      error_message = "The specified role ${each.value.role} does not exist. please remove from the list"
    }
  }
}

# resource "google_project_iam_member" "raw" {
#     for_each   = {for v in local.raw_access_roles: v.key => v...}
#     project    = "core-p-cpc-datafoundation-prj"
#     role       = each.value[0].role
#     member     = try("serviceAccount:${google_service_account.self[each.value[0].sa_key].email}","group:${each.value[0].name}")
#     depends_on = [google_service_account.self]
# }

# resource "google_project_iam_member" "eds" {
#     for_each   = {for v in local.eds_access_roles: v.key => v...}
#     project    = "eds-p-cpc-dataintegration-prj"
#     role       = each.value[0].role
#     member     = try("serviceAccount:${google_service_account.self[each.value[0].sa_key].email}","group:${each.value[0].name}")
#     depends_on = [google_service_account.self]
# }

# resource "google_project_iam_member" "ods" {
#     for_each   = {for v in local.ods_access_roles: v.key => v...}
#     project    = "ods-p-cpc-dataintegration-prj"
#     role       = each.value[0].role
#     member     = try("serviceAccount:${google_service_account.self[each.value[0].sa_key].email}","group:${each.value[0].name}")
#     depends_on = [google_service_account.self]
# }

# data "google_cloud_identity_group_lookup" "self" {
#     for_each = {for v in local.ad_iam_roles: v.key => v}
#     group_key {
#         id = each.value.member
#     }
# }

data "google_iam_role" "self" {
  for_each = {for v in concat(local.ad_iam_roles, local.sa_iam_roles): v.key => v}
  name = each.value.role
}


resource "google_project_iam_member" "ad" {
  for_each = {for v in local.ad_iam_roles: v.key => v}
  project  = google_project.self[each.value.project_name].project_id
  role     = each.value.role
  member   = "group:${each.value.member}"
  lifecycle {
    precondition {
      condition = data.google_iam_role.self[each.key].name != null
      error_message = "The specified role ${each.value.role} does not exist. please remove from the list"
    }
  }
}

resource "google_monitoring_notification_channel" "self" {
    for_each     = {for v in local.budget_alerts: v.key => v}
    display_name = "${each.value.key}_alert_notification"
    type         = each.value.type
    project      = each.value.project_name 
    labels       = {"${local.email}" = each.value.send_notification_to}
    depends_on = [ google_project.self ]
}

resource "google_billing_budget" "self" {
    for_each        = {for k, v in local.project_objects: k => v if v.budget != null}
    billing_account = each.value.billing_account
    display_name    = "${each.value.project_name} Budget Alert"
 
    budget_filter {
        projects = ["projects/${google_project.self[each.value.project_name].number}"]
    }
 
    amount {
        specified_amount {
            currency_code = "USD"
            units         = each.value.budget.amount  # Budget amount in dollars
        }
    }
 
    dynamic "threshold_rules" {
      for_each = each.value.budget.threshold_rules    # Alert at set threshold
      content {
        threshold_percent = threshold_rules.value
      }
    }
 
    all_updates_rule {
        monitoring_notification_channels = flatten([
            for t in each.value.budget.types: [
                for n in t.send_notifications_to: [
                    google_monitoring_notification_channel.self["${each.value.project_name}::${t.type}::${n}"].name 
                ] 
            ]
        ])
    }
    depends_on = [ google_project_service.self ]
}