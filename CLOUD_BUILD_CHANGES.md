# Deploying Cloud Build Changes

A brief guide on the steps required before applying Terraform configuration for Cloud Build.

## Required Steps Before Applying Terraform

### 1. Creating GitHub Token

Create a GitHub Personal Access Token with the following permissions:

- `admin:public_key`
- `admin:repo_hook`
- `repo`
- `user`
- `workflow`

**Token creation:** https://github.com/settings/tokens

⚠️ **Save the token value** - it will be needed in the next step.

### 2. Configuring Google Cloud Build in GitHub Apps

1. Go to the **Google Cloud Build GitHub App** installation page: https://github.com/apps/google-cloud-build
2. Click **"Configure"** or **"Install"**
3. Select GitHub account/organization
4. Select repository to connect
5. After installation, **save the Application ID** from the URL:
   - URL format: `https://github.com/settings/installations/XXXXXXXX`
   - The number at the end is the **Application ID** (Installation ID)

### 3. Running the Bootstrap Script

Run the bootstrap script and provide the GitHub token when prompted:

```bash
scripts/bootstrap_all.sh <PROJECT_ID> [state-bucket-name] [region]
```

**Note:** On each subsequent run of the script, you can confirm without entering the token (press Enter).

### 4. Terraform Init

Execute `terraform init -backend-config="bucket=BUCKET_NAME"`

For `BUCKET_NAME`, provide the name of the bucket created by the script from the previous step.

### 5. Terraform Plan and Apply

Execute `terraform plan` and `terraform apply` with the required variables.

**Required variables:**

- `project_id`
- `vm_user_email`
- `github_repo_url`
- `state_bucket`
- `github_app_installation_id` (Application ID from step 2)
- `cloud_build_sa`

```bash
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

Alternatively, create a `terraform.tfvars` file according to the `terraform.tfvars.example` template and use it instead of passing variables manually.

### 6. Creating a Pull Request

After successfully applying the Terraform configuration:

1. Add any changes to the repository
2. Create a Pull Request to the `main` or `master` branch
3. Cloud Build will automatically run `terraform plan` for the PR

After merging the PR, Cloud Build will automatically execute `terraform apply`.
