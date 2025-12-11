# Remote Backend Quick Reference

## TL;DR - Get Started in 3 Steps

### 1. Create Backend Infrastructure

```bash
cd /path/to/aws_deploy_with_tf
chmod +x bootstrap.sh
./bootstrap.sh
```

Answer **yes** when prompted.

### 2. Initialize Terraform with Remote Backend

```bash
cd terraform
terraform init
```

Answer **yes** to migrate local state to S3.

### 3. Verify It Works

```bash
# This should work (pulling from S3 remote backend)
terraform state list

# Also verify backend bucket exists
aws s3 ls s3://terraform-state-angelica-portfolio-production-345594607466/
```

**Done!** Your remote backend is now active.

---

## What Gets Created

| Resource | Name | Purpose |
|----------|------|---------|
| **S3 Bucket** | `terraform-state-angelica-portfolio-production-345594607466` | Stores `terraform.tfstate` with encryption + versioning |
| **DynamoDB Table** | `terraform-state-angelica-portfolio-production-locks` | Manages state locks (prevents concurrent applies) |

---

## File Changes Required

### ✅ backend.tf (Already Updated!)

The `terraform/backend.tf` is already configured with:
- S3 backend bucket name
- State file path: `angelica-portfolio/production/terraform.tfstate`
- DynamoDB lock table name
- Region: eu-west-1
- Encryption: enabled

---

## Useful Commands

### Check Current Backend Status

```bash
cd terraform
terraform state list
```

### Show Backend Configuration

```bash
cd terraform
terraform init  # Shows backend config
```

### View S3 State File

```bash
aws s3 cp \
  s3://terraform-state-angelica-portfolio-production-345594607466/angelica-portfolio/production/terraform.tfstate \
  - | jq .  # Pipe to jq for pretty-print
```

### View Previous State Versions

```bash
aws s3api list-object-versions \
  --bucket terraform-state-angelica-portfolio-production-345594607466 \
  --prefix angelica-portfolio/production/terraform.tfstate
```

### Force Unlock (Emergency Only!)

```bash
# List locks
aws dynamodb scan \
  --table-name terraform-state-angelica-portfolio-production-locks \
  --region eu-west-1

# Force unlock (use with extreme caution)
terraform force-unlock <LOCK-ID>
```

---

## Benefits

✓ **Shared State** - Team members work with same state file  
✓ **Locking** - DynamoDB prevents concurrent modifies  
✓ **Encryption** - Sensitive data encrypted at rest  
✓ **Versioning** - Rollback to previous versions  
✓ **Auditability** - CloudTrail logs all changes  
✓ **CI/CD Ready** - GitHub Actions automatically uses remote backend  

---

## Security

- ✅ S3 public access is **blocked**
- ✅ State files are **encrypted** at rest (AES256)
- ✅ Only IAM users with S3 permissions can access
- ✅ DynamoDB table has restricted access
- ✅ CloudTrail logs all state modifications

---

## Troubleshooting

### ❌ "Backend initialization required" Error

```bash
./bootstrap.sh  # Create backend resources
cd terraform
terraform init  # Re-initialize
```

### ❌ AWS Credentials Error

```bash
aws sts get-caller-identity  # Check current credentials
aws configure  # Re-configure if needed
```

### ❌ "Error acquiring the state lock"

Someone else has a terraform operation in progress. Wait a few minutes, or:

```bash
terraform force-unlock <LOCK-ID>  # Emergency only
```

---

## GitHub Actions Integration

**No additional setup needed!** Your CI/CD pipeline already:
1. Reads backend config from `backend.tf`
2. Uses AWS credentials from GitHub Secrets
3. Automatically acquires/releases DynamoDB locks
4. Prevents concurrent terraform applies

---

## Next Steps

1. **Run bootstrap.sh** to create S3 + DynamoDB
2. **Run terraform init** to connect to remote backend
3. **Verify** with `terraform state list`
4. **Continue deployment** - everything else works normally!

---

## References

- Full guide: `BACKEND_SETUP_GUIDE.md`
- Bootstrap script: `bootstrap.sh`
- Backend config: `terraform/backend.tf`

