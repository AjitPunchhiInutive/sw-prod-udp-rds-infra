# GCP Authentication Action

Securely authenticates to Google Cloud Platform using Workload Identity Federation (OIDC).

## Overview

This action implements keyless authentication to GCP using GitHub's OIDC token and GCP's Workload Identity Federation. This eliminates the need to store long-lived service account keys.

## Security Benefits

✅ **No Static Credentials**: Uses temporary tokens  
✅ **Audit Trail**: Full GitHub Actions audit in GCP  
✅ **Token Expiration**: Automatic token rotation  
✅ **Scope Limitation**: Fine-grained IAM permissions  

## Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `environment` | Yes | - | Target environment (dev, test, prod) |
| `project_id` | Yes | - | GCP Project ID |
| `workload_identity_provider` | Yes | - | GCP Workload Identity Provider resource path |
| `gcp_service_account` | No | - | GCP Service Account email to impersonate |

## Outputs

None (configures gcloud CLI for subsequent steps)

## Example Usage

### Basic Setup
```yaml
- uses: southwire/gh-actions-library/.github/actions/gcp/auth@main
  with:
    environment: dev
    project_id: ${{ secrets.GCP_NONPROD_PROJECT_ID }}
    workload_identity_provider: ${{ secrets.GCP_NONPROD_WORKLOAD_IDENTITY_PROVIDER }}
```

### With Service Account Impersonation
```yaml
- uses: southwire/gh-actions-library/.github/actions/gcp/auth@main
  with:
    environment: prod
    project_id: ${{ secrets.GCP_PROD_PROJECT_ID }}
    workload_identity_provider: ${{ secrets.GCP_PROD_WORKLOAD_IDENTITY_PROVIDER }}
    gcp_service_account: terraform@myproject.iam.gserviceaccount.com
```

## What It Does

1. Uses GitHub OIDC token to authenticate to GCP
2. Exchanges GitHub token for GCP access token
3. Configures gcloud CLI
4. Validates authentication status
5. Outputs account and project information

## Prerequisites

1. **GCP Workload Identity Federation Setup**
   - Create a Workload Identity Pool
   - Configure GitHub as OIDC provider
   - Create Workload Identity Provider
   - Bind GitHub repository to service account

2. **GitHub Secrets** (required)
   - `GCP_*_PROJECT_ID`: Your GCP Project ID
   - `GCP_*_WORKLOAD_IDENTITY_PROVIDER`: Provider resource path

3. **Permissions Required**
   - Repository must be public (for actions discovery)
   - GitHub token must have `id-token: write` permission

## Troubleshooting

### Authentication Fails with "Not Found"
**Cause**: Workload Identity Provider path is incorrect  
**Solution**: Verify provider resource path format: `projects/{PROJECT_ID}/locations/global/workloadIdentityPools/{POOL_ID}/providers/{PROVIDER_ID}`

### "Permission Denied" After Authentication
**Cause**: Service account lacks required IAM roles  
**Solution**: Ensure service account has roles:
- `roles/compute.admin` (for Compute resources)
- `roles/storage.admin` (for GCS Backend)
- `roles/resourcemanager.projectEditor` (for full project access)

### gcloud Command Not Found
**Cause**: gcloud CLI not installed  
**Solution**: Action automatically sets up gcloud; ensure runner has internet access

## Related Actions

- [terragrunt/init](../terragrunt/init/) - Initialize after GCP auth
- [terragrunt/plan](../terragrunt/plan/) - Plan infrastructure changes

## See Also

- [GCP Workload Identity Federation Docs](https://cloud.google.com/docs/authentication/workload-identity-federation)
- [GitHub OIDC Token Documentation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
