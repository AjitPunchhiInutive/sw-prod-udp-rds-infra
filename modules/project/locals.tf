locals {
    kms_supported_serviceagents = [
        "cloudkms.googleapis.com",
        "secretmanager.googleapis.com",
        "storage.googleapis.com",
        "compute.googleapis.com"
    ]
    apis_to_enable = [
        "clouderrorreporting.googleapis.com",
        "networkconnectivity.googleapis.com",
        "networkmanagement.googleapis.com",
    ]
    approved_iam_roles = [
        "roles/secretmanager.secretAccessor",
        "roles/editor",
        "roles/cloudkms.cryptoKeyEncrypterDecrypter",
    ]
    reader_iam_roles = ["roles/bigquery.dataViewer", "roles/bigquery.jobUser", "roles/storage.objectViewer"]
    project_objects = {for p in var.project_objects: p.project_name => merge(p, {
        parent_type = split("/", p.parent)[0],
        parent_id = split("/", p.parent)[1],
        api_services = distinct(concat(local.kms_supported_serviceagents,local.apis_to_enable, p.services))
        kms_supported_serviceagents = local.kms_supported_serviceagents,
        labels = {for k, v in p.labels: k => lower(v)}
    }) if p != null && p.deploy}
    project_services = flatten([
        for p in local.project_objects: [
            for s in p.api_services: merge(p, {service = s, key = "${p.project_name}_${s}"})
        ]
    ])
    project_kms_supported_serviceagents = flatten([
        for p in local.project_objects: [
            for s in p.kms_supported_serviceagents: merge(p, {service = s, key = "${p.project_name}_kms_${s}"})
        ]
    ])
    project_policies_boolean = flatten([
        for p in local.project_objects: [
            for k, v in p.policy_boolean: merge(p, {constraint_key = k,constraint_value = v,key="${p.project_name}_${k}"})
        ]
    ])
    project_policy_list = flatten([
        for p in local.project_objects: [
            for k, v in p.policy_list: merge(p, {constraint_key = k,constraint_value = v,key="${p.project_name}_${k}"})
        ]
    ])
    iap_tunnel_members_list = flatten([
        for p in local.project_objects: [
            for m in p.iap_tunnel_members_list: merge(p, {member = m, key = "${p.project_name}_${m}"})
        ]
    ])
    kms_encrypterdecrypter_members_list = flatten([
        for p in local.project_objects: [
            for m in p.kms_encrypterdecrypter_members_list: merge(p, {member = m, key = "${p.project_name}_${m}"})
        ]
    ])
    service_accounts = flatten([
        for p in local.project_objects: [
            for sa in p.service_accounts: merge(sa, {
                project_name = p.project_name,
                key = "${p.project_name}::${sa.name}",
                reader_iam_roles = local.reader_iam_roles
            }) if p.service_accounts != null
        ]
    ])
    sa_iam_roles = flatten([
        for sa in local.service_accounts: [
            for r in sa.iam_roles: merge(sa, {
                role = r,
                sa_key = sa.key
                project_name = sa.project_name,
                key = "${sa.key}::${r}"
            }) if sa.iam_roles != null
        ]
    ])
    ad_groups = flatten([
        for p in local.project_objects: [
            for ad in p.ad_groups: merge(ad, {project_name = p.project_name})
        ]
    ])
    raw_access_roles = concat(flatten([
        for sa in local.service_accounts: [
            for r in sa.reader_iam_roles: merge(sa, {
                role = r,
                sa_key = sa.key
                project_name = sa.project_name,
                key = "${sa.key}::${r}",
            }) if sa.raw_read_access
        ]
    ]), flatten([
        for ad in local.ad_groups: [
            for r in local.reader_iam_roles: merge(ad, {
                role = r,
                project_name = ad.project_name,
                key = "${ad.name}::${r}",
            }) if ad.raw_read_access
        ]
    ]))
    eds_access_roles = concat(flatten([
        for sa in local.service_accounts: [
            for r in sa.reader_iam_roles: merge(sa, {
                role = r,
                sa_key = sa.key
                project_name = sa.project_name,
                key = "${sa.key}::${r}",
            }) if sa.eds_read_access
        ]
    ]), flatten([
        for ad in local.ad_groups: [
            for r in local.reader_iam_roles: merge(ad, {
                role = r,
                project_name = ad.project_name,
                key = "${ad.name}::${r}",
            }) if ad.eds_read_access
        ]
    ]))
    ods_access_roles = concat(flatten([
        for sa in local.service_accounts: [
            for r in sa.reader_iam_roles: merge(sa, {
                role = r,
                sa_key = sa.key
                project_name = sa.project_name,
                key = "${sa.key}::${r}",
            }) if sa.ods_read_access
        ]
    ]), flatten([
        for ad in local.ad_groups: [
            for r in local.reader_iam_roles: merge(ad, {
                role = r,
                project_name = ad.project_name,
                key = "${ad.name}::${r}",
            }) if ad.ods_read_access
        ]
    ]))
    ad_iam_roles = flatten([
        for ad in local.ad_groups: [
            for r in ad.iam_roles: merge(ad, {
                role = r,
                member = ad.name
                project_name = ad.project_name,
                key = "${ad.project_name}::${ad.name}::${r}"
            }) if ad.iam_roles != null
        ]
    ])
    budget_alerts = flatten([
        for p in local.project_objects: [
            for t in p.budget.types: [
               for n in t.send_notifications_to: merge(p, {type = t.type,send_notification_to = n, key = "${p.project_name}::${t.type}::${n}"})
            ] if p.budget != null
        ]
    ])
    pubsub = "pubsub"
    email  = "email_address"
    pubsub_budget_alerts = flatten([
        for p in local.project_objects: [
            for t in p.budget.types: [
               for n in t.send_notifications_to: merge(p, {type = t.type,send_notification_to = n, key = "${p.project_name}::${t.type}::${n}"}) if t.type == local.pubsub
            ] if p.budget != null
        ]
    ])

}