# Terragrunt Actions

Collection of composable GitHub Actions for Terragrunt-based infrastructure management.

## Available Actions

### terragrunt/init
Initializes Terragrunt working directory and downloads remote modules.

**Documentation**: [init/README.md](init/README.md)

### terragrunt/validate
Validates Terraform configurations for syntax and type errors.

**Documentation**: [validate/README.md](validate/README.md)

### terragrunt/lint
Runs TFLint to identify Terraform best practice violations.

**Documentation**: [lint/README.md](lint/README.md)

### terragrunt/plan
Generates and saves Terraform execution plan.

**Documentation**: [plan/README.md](plan/README.md)

### terragrunt/apply
Applies pre-generated Terraform plan to infrastructure.

**Documentation**: [apply/README.md](apply/README.md)

### terragrunt/format
Formats Terraform code according to style guidelines.

**Documentation**: [format/README.md](format/README.md)

## Typical Pipeline Flow

```
init
  ↓
validate
  ↓
lint
  ↓
plan (with artifact upload)
  ↓
apply (with artifact download)
```

## Common Configuration

All Terragrunt actions accept:
- `workingDirectory`: Path to Terragrunt configuration
- `environment`: Target environment name
- `tfLog`: Terraform log level (optional)

## Best Practices

1. **Always init before validate**: Terragrunt needs initialized modules
2. **Save plans as artifacts**: Essential for auditability and apply phase
3. **Use consistent environments**: Match environment names across actions
4. **Enable logging for debugging**: Set `tfLog: DEBUG` when troubleshooting
5. **Separate plan and apply**: Different jobs enable approval gates

## Examples

### Full Pipeline
```yaml
jobs:
  plan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: southwire/gh-actions-library/.github/actions/terragrunt/init@main
        with:
          workingDirectory: projects/dev/src
          environment: dev
      
      - uses: southwire/gh-actions-library/.github/actions/terragrunt/validate@main
        with:
          workingDirectory: projects/dev/src
          environment: dev
      
      - uses: southwire/gh-actions-library/.github/actions/terragrunt/lint@main
        with:
          workingDirectory: projects/dev/src
          environment: dev
      
      - uses: southwire/gh-actions-library/.github/actions/terragrunt/plan@main
        with:
          workingDirectory: projects/dev/src
          environment: dev
      
      - uses: actions/upload-artifact@v4
        with:
          name: tfplan
          path: projects/dev/src/tfplan.out
          retention-days: 30

  apply:
    needs: plan
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: southwire/gh-actions-library/.github/actions/gcp/auth@main
        with:
          environment: dev
          project_id: ${{ secrets.GCP_NONPROD_PROJECT_ID }}
          workload_identity_provider: ${{ secrets.GCP_NONPROD_WORKLOAD_IDENTITY_PROVIDER }}
      
      - uses: actions/download-artifact@v4
        with:
          name: tfplan
          path: projects/dev/src
      
      - uses: southwire/gh-actions-library/.github/actions/terragrunt/apply@main
        with:
          workingDirectory: projects/dev/src
          environment: dev
```

## Troubleshooting

### Module Not Found
**Issue**: `Error: Module not found`  
**Solution**: Ensure `init` runs before other actions

### Plan File Not Found
**Issue**: `tfplan.out: No such file`  
**Solution**: Verify artifact is uploaded and retention period hasn't expired

### Permission Denied
**Issue**: `Access denied` when running terragrunt  
**Solution**: Check GCP authentication and IAM permissions

### TFLint Failures
**Issue**: Lint errors block pipeline  
**Solution**: Review TFLint configuration in `.tflint.hcl`

## Environment Variables

Actions automatically set:
- `TF_LOG`: From `tfLog` input
- `PARALLELISM`: From `parallelism` input (plan action only)
- `TERRAGRUNT_GITHUB_ORG_TOKEN`: From secrets for module downloads

## Related Documentation

- [Terragrunt Documentation](https://terragrunt.gruntwork.io/)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices.html)
- [TFLint Rules](https://github.com/terraform-linters/tflint/blob/master/docs/rules/README.md)
