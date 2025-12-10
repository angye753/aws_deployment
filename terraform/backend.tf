# Terraform Backend Configuration
# Uncomment and configure the S3 backend below for remote state management
# This is HIGHLY RECOMMENDED for production deployments

# Note: You must create the S3 backend bucket FIRST manually, then uncomment below
# Steps:
# 1. Create S3 bucket: aws s3 mb s3://terraform-state-<account-id>-<region>
# 2. Enable versioning on that bucket
# 3. Enable server-side encryption on that bucket
# 4. Create DynamoDB table: terraform-locks (partition key: LockID)
# 5. Uncomment the backend block below
# 6. Run: terraform init -migrate-state

/*
terraform {
  backend "s3" {
    bucket         = "terraform-state-angelica-portfolio"  # Change to your backend bucket
    key            = "portfolio/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
*/

# For now, using local state (development/initial setup)
# This file can be deleted after remote backend is configured
