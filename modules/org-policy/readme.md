# GCP Folder Organization Policy - Terraform Module

This Terraform module manages **Google Cloud Folder Organization Policies**, supporting both **boolean** and **list** policy types.

---

## Table of Contents

- [Overview](#overview)
- [Usage](#usage)
  - [Boolean Policy Example](#boolean-policy-example)
  - [List Policy Example](#list-policy-example)
  - [Combined Example](#combined-example)
- [Input Variables](#input-variables)
  - [folder_org_policies](#folder_org_policies)
  - [policy_boolean](#policy_boolean)
  - [policy_list](#policy_list)
- [Outputs](#outputs)
- [Resources Created](#resources-created)
- [YAML Configuration Reference](#yaml-configuration-reference)
  - [Minimal Example](#minimal-example)
  - [Full Example](#full-example)
---

## Overview

This module allows you to enforce organization policies at the **GCP folder level** using a simple YAML-driven configuration. It supports:

- **Boolean Policies** — Enforce or disable a constraint (e.g., disable service account key creation).
- **List Policies** — Allow or deny specific values for a constraint (e.g., restrict allowed policy member domains).
- **Deploy Flag** — Toggle deployment on/off without removing configuration.


---

## Usage

### Boolean Policy Example

Enforce or disable a single boolean constraint on a folder:

```yaml
folder_org_policies:
  deploy: true
  folder_id: "123456789012"
  policy_boolean:
    constraints/iam.disableServiceAccountKeyCreation: true
  policy_list: {}
```

### List Policy Example

Restrict allowed policy member domains:

```yaml
folder_org_policies:
  deploy: true
  folder_id: "123456789012"
  policy_boolean: {}
  policy_list:
    constraints/iam.allowedPolicyMemberDomains:
      inherit_from_parent: false
      suggested_value: ""
      status: true
      values:
        - "example.com"
```

> **Note:** `status: true` → creates an **allow** rule. `status: false` → creates a **deny** rule.

### Combined Example

Apply multiple boolean and list policies together:

```yaml
folder_org_policies:
  deploy: true
  folder_id: "123456789012"
  policy_boolean:
    constraints/iam.disableServiceAccountKeyCreation: true
    constraints/iam.NoServiceAccountExternalKeyCreation: true
    constraints/iam.disableServiceAccountKeyUpload: false
  policy_list:
    constraints/iam.allowedPolicyMemberDomains:
      inherit_from_parent: false
      suggested_value: ""
      status: true
      values:
        - "southwire.com"
    constraints/compute.restrictSharedVpcSubnetworks:
      inherit_from_parent: true
      suggested_value: ""
      status: false
      values:
        - "projects/my-project/regions/us-central1/subnetworks/default"
```

---

## Input Variables

### folder_org_policies

| Attribute        | Type                  | Required | Description                              |
|------------------|-----------------------|----------|------------------------------------------|
| `deploy`         | `bool`                | Yes      | Enable or disable policy deployment      |
| `folder_id`      | `string`              | Yes      | GCP Folder ID to apply policies to       |
| `policy_boolean` | `map(bool)`           | No       | Map of boolean constraints and values    |
| `policy_list`    | `map(object)` (below) | No       | Map of list constraints and their config |

### policy_boolean

A simple key-value map:

```
constraint_name: true/false
```

| Value   | Effect                          |
|---------|---------------------------------|
| `true`  | Constraint is **enforced**      |
| `false` | Constraint is **not enforced**  |

### policy_list

Each list policy entry supports:

| Attribute             | Type           | Default | Description                                       |
|-----------------------|----------------|---------|---------------------------------------------------|
| `inherit_from_parent` | `bool`         | `false` | Inherit policy from parent resource                |
| `suggested_value`     | `string`       | `""`    | Suggested value for the constraint                 |
| `status`              | `bool`         | —       | `true` = allow list, `false` = deny list           |
| `values`              | `list(string)` | —       | List of values to allow or deny                    |

---

## Outputs

| Output              | Description                               |
|---------------------|-------------------------------------------|
| `boolean_policy_ids`| Map of boolean policy resource IDs        |
| `list_policy_ids`   | Map of list policy resource IDs           |

---

## Resources Created

| Resource                                    | Description                         |
|---------------------------------------------|-------------------------------------|
| `google_folder_organization_policy.boolean_policies` | Boolean org policies on the folder |
| `google_folder_organization_policy.list_policies`    | List org policies on the folder    |

---

## YAML Configuration Reference

### Minimal Example

Deploy with only a boolean policy:

```yaml
folder_org_policies:
  deploy: true
  folder_id: "123456789012"
  policy_boolean:
    constraints/iam.disableServiceAccountKeyCreation: true
```

### Full Example

```yaml
folder_org_policies:
  deploy: true
  folder_id: "123456789012"
  policy_boolean:
    constraints/iam.disableServiceAccountKeyCreation: true
    constraints/iam.NoServiceAccountExternalKeyCreation: true
    constraints/iam.disableServiceAccountKeyUpload: false
  policy_list:
    constraints/iam.allowedPolicyMemberDomains:
      inherit_from_parent: false
      suggested_value: ""
      status: true
      values:
        - "southwire.com"
```

### Disable Deployment

Set `deploy: false` to skip creating any resources without deleting config:

```yaml
folder_org_policies:
  deploy: false
  folder_id: "123456789012"
  policy_boolean:
    constraints/iam.disableServiceAccountKeyCreation: true
```

---