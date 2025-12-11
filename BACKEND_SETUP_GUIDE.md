# Terraform Remote Backend Setup Guide

## Overview

This guide explains how to set up a remote Terraform backend using AWS S3 and DynamoDB. A remote backend provides:

- **Shared State**: Team members work with the same state file
- **State Locking**: DynamoDB prevents concurrent modifications
- **Encryption**: Sensitive data encrypted at rest in S3
- **Versioning**: S3 versioning enables rollback capability
- **Auditability**: CloudTrail logs all state changes

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                 Remote Backend Setup                    │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  S3 Backend Bucket                                      │
│  ├─ terraform.tfstate (encrypted)                      │
│  ├─ terraform.tfstate.backup (previous versions)       │
│  └─ Versioning Enabled (history)                       │
│                                                         │
│  DynamoDB Lock Table                                   │
│  ├─ Partition Key: LockID                              │
│  └─ Prevents concurrent terraform apply                │
│                                                         │
│  Security                                              │
│  ├─ Public Access Blocked                              │
│  ├─ AES256 Encryption                                  │
│  └─ IAM Policies (team access control)                 │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Step-by-Step Setup

### Step 1: Run the Bootstrap Script

The bootstrap script automates the creation of S3 and DynamoDB resources:

```bash
cd /path/to/aws_deploy_with_tf
chmod +x bootstrap.sh
./bootstrap.sh
```

**What the script does:**
1. Verifies AWS credentials and Terraform installation
2. Reads configuration from `terraform/terraform.tfvars`
3. Gets your AWS account ID via `aws sts get-caller-identity`
4. Creates S3 backend bucket with:
   - Versioning enabled
   - Server-side encryption (AES256)
   - Public access blocked
5. Creates DynamoDB table for state locks
6. Displays the backend configuration to use

**Example output:**
```
✓ Backend infrastructure created successfully!

Next Steps:
1. Update terraform/backend.tf with the following configuration:

   terraform {
     backend "s3" {
       bucket       = "terraform-state-angelica-portfolio-production-345594607466"
       key          = "angelica-portfolio/production/terraform.tfstate"
       region       = "eu-west-1"
       encrypt      = true
       use_lockfile = true
     }
   }

2. Run: cd terraform && terraform init
3. Answer 'yes' when prompted to copy state to S3 backend
```

### Step 2: Verify Bootstrap Completed

Check that the S3 bucket and DynamoDB table were created:

```bash
# List backend bucket
aws s3 ls s3://terraform-state-angelica-portfolio-production-345594607466

# Verify DynamoDB table
aws dynamodb describe-table \
  --table-name terraform-state-angelica-portfolio-production-locks \
  --region eu-west-1
```

### Step 3: Update backend.tf (Already Done!)

The `terraform/backend.tf` file is already configured with your backend details:

```hcl
terraform {
  backend "s3" {
    bucket       = "terraform-state-angelica-portfolio-production-345594607466"
    key          = "angelica-portfolio/production/terraform.tfstate"
    region       = "eu-west-1"
    encrypt      = true
    use_lockfile = true
  }
}
```

### Step 4: Initialize Terraform with Remote Backend

```bash
cd terraform
terraform init
```

**Terraform will prompt:**
```
Do you want to copy existing state to the new backend?
```

Answer **yes** to migrate your local state to S3:

```bash
# Answer 'yes' when prompted
terraform init
# ...
# terraform will ask: "Do you want to copy existing state to the new backend?"
# Type: yes
```

**After migration:**
- Local `terraform.tfstate` and `terraform.tfstate.backup` are still present (safe to keep or delete)
- Your state is now in S3
- DynamoDB table will automatically lock during apply operations

### Step 5: Verify Remote State is Working

```bash
cd terraform

# Check that state is now remote
terraform state list

# The output should work (pulling from S3)
# If it works, remote backend is active!

# You can also verify by checking S3
aws s3 ls s3://terraform-state-angelica-portfolio-production-345594607466/
# Should show: angelica-portfolio/production/terraform.tfstate
```

## Configuration Details

### S3 Backend Bucket

**Naming Convention:**
```
terraform-state-{project-name}-{environment}-{account-id}
```

**Example:** `terraform-state-angelica-portfolio-production-345594607466`

**Configuration:**
- **Versioning**: Enabled (allows rollback)
- **Encryption**: AES256 (all objects encrypted at rest)
- **Public Access**: Blocked (only IAM users with S3 permissions can access)
- **Bucket Policies**: Can be configured for team access

### DynamoDB Lock Table

**Naming Convention:**
```
terraform-state-{project-name}-{environment}-locks
```

**Example:** `terraform-state-angelica-portfolio-production-locks`

**Configuration:**
- **Partition Key**: LockID (string)
- **Billing Mode**: PAY_PER_REQUEST (cost-effective for state locking)
- **Item TTL**: Optional (clean up old locks after 24 hours)

### State File Path

```
s3://terraform-state-angelica-portfolio-production-345594607466/
└── angelica-portfolio/
    └── production/
        ├── terraform.tfstate
        ├── terraform.tfstate.backup
        └── [previous versions if versioning enabled]
```

## Team Access Control

To allow team members to use the remote backend, grant them IAM permissions:

### Required S3 Permissions

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "TerraformStateAccess",
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketVersioning"
      ],
      "Resource": "arn:aws:s3:::terraform-state-angelica-portfolio-production-345594607466"
    },
    {
      "Sid": "TerraformStateObject",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::terraform-state-angelica-portfolio-production-345594607466/*"
    }
  ]
}
```

### Required DynamoDB Permissions

```json
{
  "Sid": "TerraformStateLocking",
  "Effect": "Allow",
  "Action": [
    "dynamodb:DescribeTable",
    "dynamodb:GetItem",
    "dynamodb:PutItem",
    "dynamodb:DeleteItem"
  ],
  "Resource": "arn:aws:dynamodb:eu-west-1:ACCOUNT-ID:table/terraform-state-angelica-portfolio-production-locks"
}
```

## Troubleshooting

### Issue: "Error: Backend initialization required"

**Cause**: Terraform.backend config exists but backend bucket doesn't

**Solution**:
```bash
./bootstrap.sh  # Create the backend resources
cd terraform
terraform init  # Initialize with new backend
```

### Issue: "Error: Error acquiring the state lock"

**Cause**: Someone else has a lock, or lock is stuck

**Solution**:
```bash
# Check lock status
aws dynamodb scan --table-name terraform-state-angelica-portfolio-production-locks --region eu-west-1

# Force unlock (use with caution!)
terraform force-unlock <LOCK-ID>
```

### Issue: "Access Denied" errors

**Cause**: IAM user doesn't have S3/DynamoDB permissions

**Solution**:
1. Ensure IAM user has permissions listed in "Team Access Control" section
2. Verify AWS credentials are correct
3. Test with: `aws s3 ls s3://terraform-state-angelica-portfolio-production-345594607466/`

### Issue: "InvalidClientTokenId" when running terraform init

**Cause**: AWS credentials in environment are invalid/expired

**Solution**:
```bash
# Check current credentials
aws sts get-caller-identity

# If error, reconfigure credentials
aws configure

# Verify
aws s3 ls
```

## Rollback Procedures

### Rollback to Previous State Version

Since S3 versioning is enabled, you can access previous state files:

```bash
# List all versions
aws s3api list-object-versions \
  --bucket terraform-state-angelica-portfolio-production-345594607466 \
  --prefix angelica-portfolio/production/terraform.tfstate

# Get a specific version
aws s3api get-object \
  --bucket terraform-state-angelica-portfolio-production-345594607466 \
  --key angelica-portfolio/production/terraform.tfstate \
  --version-id <VERSION-ID> \
  terraform.tfstate.old

# If needed, copy old version back (manual operation)
aws s3api put-object \
  --bucket terraform-state-angelica-portfolio-production-345594607466 \
  --key angelica-portfolio/production/terraform.tfstate \
  --body terraform.tfstate.old
```

## Migration from Local to Remote Backend

If you already have local state:

### Option 1: Automatic Migration (Recommended)

```bash
cd terraform

# terraform init will detect backend.s3 and ask about migration
terraform init

# When prompted:
# "Do you want to copy existing state to the new backend?"
# Answer: yes
```

### Option 2: Manual Migration

```bash
cd terraform

# Backup local state first!
cp terraform.tfstate terraform.tfstate.backup

# Initialize with backend
terraform init

# When prompted about copying state: yes

# Verify state was copied
terraform state list
```

## GitHub Actions Integration

To use remote backend in CI/CD:

### 1. No Additional Configuration Needed

The backend.tf already contains the S3 backend configuration. When GitHub Actions runs `terraform init`, it will automatically use the remote backend.

### 2. Ensure GitHub Actions Has AWS Credentials

GitHub Secrets should have:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`

See `GITHUB_SECRETS_GUIDE.md` for setup.

### 3. Pipeline Will Automatically Lock State

During CI/CD:
```
terraform init  # Connects to S3 backend
terraform plan  # Acquires lock from DynamoDB
terraform apply # Applies changes with lock held
# Lock automatically released on success/failure
```

## Security Best Practices

### ✓ Do This

- ✅ Enable S3 versioning (for rollback capability)
- ✅ Enable S3 encryption (encrypt sensitive data)
- ✅ Block public access (prevent accidental exposure)
- ✅ Use IAM roles for authentication (not access keys if possible)
- ✅ Enable CloudTrail logging (audit state changes)
- ✅ Enable S3 MFA Delete (prevent accidental deletion)
- ✅ Limit DynamoDB table access to needed users only
- ✅ Store AWS credentials securely (AWS Secrets Manager, GitHub Secrets)

### ✗ Don't Do This

- ❌ Don't commit terraform.tfstate to Git (contains sensitive data)
- ❌ Don't share AWS access keys in code/documentation
- ❌ Don't disable S3 encryption
- ❌ Don't allow public access to state bucket
- ❌ Don't delete DynamoDB lock table while terraform is running

## Monitoring and Logging

### Enable CloudTrail for State Changes

```bash
# CloudTrail logs all S3 API calls on state bucket
# Check AWS CloudTrail console for:
# - GetObject (terraform reading state)
# - PutObject (terraform writing state)
# - DeleteObject (terraform cleanup)
```

### Monitor Lock Table Activity

```bash
# View recent lock events
aws dynamodb query \
  --table-name terraform-state-angelica-portfolio-production-locks \
  --region eu-west-1
```

### Monitor S3 Bucket for Unusual Access

```bash
# Check for anomalous activity
aws s3api get-bucket-logging \
  --bucket terraform-state-angelica-portfolio-production-345594607466
```

## FAQ

**Q: Can multiple people use the same backend?**
A: Yes! DynamoDB locking prevents simultaneous applies. Multiple reads are allowed.

**Q: What if someone deletes the S3 bucket?**
A: Disaster! Keep backups. With versioning enabled, you can recover old states, but current state is lost.

**Q: Can I use a different region for the backend?**
A: Yes, but keep it in a central region. The default (eu-west-1) matches your deployment region.

**Q: Do I still need local terraform.tfstate?**
A: No, you can delete it after migration to remote backend. Terraform ignores it when backend is configured.

**Q: How much does it cost?**
A: Minimal:
- S3: ~$0.023/GB/month (for terraform.tfstate, typically <1MB)
- DynamoDB: $0 with PAY_PER_REQUEST (only charged for reads/writes)
- Total: Usually <$1/month

## References

- [Terraform S3 Backend Documentation](https://www.terraform.io/language/settings/backends/s3)
- [AWS S3 Documentation](https://docs.aws.amazon.com/s3/)
- [AWS DynamoDB Documentation](https://docs.aws.amazon.com/dynamodb/)
- [Terraform State Locking](https://www.terraform.io/language/state/locking)
