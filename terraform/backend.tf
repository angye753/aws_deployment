# ============================================================================
# Terraform Remote Backend Configuration (S3 + DynamoDB)
# ============================================================================
#
# This configuration enables remote state management for Terraform.
# Remote state is stored in S3, with state locks managed by DynamoDB.
#
# IMPORTANT: Before enabling this backend, run the bootstrap script:
#   ./bootstrap.sh
#
# The bootstrap script will:
#   1. Create S3 backend bucket with versioning + encryption
#   2. Create DynamoDB table for state locks
#   3. Show you the exact configuration to use below
#
# After bootstrap completes, uncomment the backend block below and run:
#   cd terraform
#   terraform init
#   (Terraform will ask if you want to migrate local state to S3 - answer yes)
#
# ============================================================================

terraform {
  backend "s3" {
    bucket       = "terraform-state-angelica-portfolio-production-345594607466"
    key          = "angelica-portfolio/production/terraform.tfstate"
    region       = "eu-west-1"
    encrypt      = true
    use_lockfile = true
  }
}

# ============================================================================
# Backend Benefits for Production Use
# ============================================================================
#
# ✓ Shared State: Team members access the same state file (not local copies)
# ✓ Locking: DynamoDB prevents concurrent terraform apply operations
# ✓ Versioning: S3 versioning allows rollback to previous state
# ✓ Encryption: Sensitive data encrypted at rest in S3
# ✓ Backup: S3 versioning provides automatic backup capability
# ✓ Auditability: CloudTrail logs all state modifications
#
# ============================================================================
