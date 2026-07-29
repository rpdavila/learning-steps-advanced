# Learning Steps Azure

This repository contains an Azure learning project with Terraform infrastructure, an application container, and GitHub Actions security checks.

## Repository layout

- `infra-terraform/` — Terraform configuration for Azure resources
- `learningsteps/` — application code, Dockerfile, and local development files
- `.github/workflows/` — GitHub Actions workflows for secret scanning, IaC analysis, and Docker image scanning

## GitHub Actions workflows

The repository includes separate workflows for:

- `secret-scan.yml`: runs `trufflehog` on source and infra changes
- `iac-static-analysis.yml`: runs `tfsec` and `checkov` for Terraform files in `infra-terraform/`
- `trivy-iac.yml`: runs Trivy IaC scans against `infra-terraform/`
- `image-build-scan.yml`: builds the Docker image from `learningsteps/`, scans it with Trivy, and pushes to ACR on success

> The image push step is gated by `if: success()`, so it only runs if the build and scan steps pass.

## Required GitHub secrets

Add these repository secrets before enabling Docker push or workflows that require Azure registry access:

- `ACR_LOGIN_SERVER` (e.g. `myregistry.azurecr.io`)
- `ACR_USERNAME`
- `ACR_PASSWORD`

## Local development

From the repo root:

```powershell
cd infra-terraform
tfenv install
terraform init
terraform plan
terraform apply
```

For app development:

```powershell
cd learningsteps
# use your virtual environment or python tooling
```

## .gitignore

The root `.gitignore` excludes Terraform state, plans, secrets, Python virtual environments, editor files, and other generated artifacts.

## Branch protection

For safety, configure GitHub branch protection to require workflow status checks before merging.
