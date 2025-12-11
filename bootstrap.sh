#!/usr/bin/env zsh
# ============================================================================
# Terraform Backend Bootstrap Script
# ============================================================================
# Purpose: Create S3 backend bucket and DynamoDB lock table for Terraform state
# 
# This script MUST be run BEFORE terraform init to set up remote state management
# It creates the S3 bucket and DynamoDB table that Terraform will use to store
# the terraform.tfstate file and state locks.
#
# Usage: ./bootstrap.sh
# ============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
TERRAFORM_DIR="terraform"
TFVARS_FILE="${TERRAFORM_DIR}/terraform.tfvars"
BACKEND_PREFIX="terraform-state"

# Helper functions
log_info() {
    echo -e "${BLUE}ℹ  ${1}${NC}"
}

log_success() {
    echo -e "${GREEN}✓ ${1}${NC}"
}

log_warn() {
    echo -e "${YELLOW}⚠  ${1}${NC}"
}

log_error() {
    echo -e "${RED}✗ ${1}${NC}"
}

# Verify prerequisites
log_info "Verifying prerequisites..."

if ! command -v aws &> /dev/null; then
    log_error "AWS CLI not found. Please install: https://aws.amazon.com/cli/"
    exit 1
fi
log_success "AWS CLI found"

if ! command -v terraform &> /dev/null; then
    log_error "Terraform not found. Please install: https://www.terraform.io/downloads"
    exit 1
fi
log_success "Terraform found"

if ! command -v jq &> /dev/null; then
    log_warn "jq not found. Some features will be limited. Install with: brew install jq"
fi

# Verify terraform.tfvars exists
if [[ ! -f "${TFVARS_FILE}" ]]; then
    log_error "File not found: ${TFVARS_FILE}"
    exit 1
fi
log_success "Found terraform.tfvars"

# Extract variables from terraform.tfvars
log_info "Reading configuration from terraform.tfvars..."

PROJECT_NAME=$(sed -nE 's/^[[:space:]]*project_name[[:space:]]*=[[:space:]]*"?([^"]+)"?/\1/p' "${TFVARS_FILE}")
ENVIRONMENT=$(sed -nE 's/^[[:space:]]*environment[[:space:]]*=[[:space:]]*"?([^"]+)"?/\1/p' "${TFVARS_FILE}")
AWS_REGION=$(sed -nE 's/^[[:space:]]*aws_region[[:space:]]*=[[:space:]]*"?([^"]+)"?/\1/p' "${TFVARS_FILE}")

if [[ -z "${PROJECT_NAME}" ]] || [[ -z "${ENVIRONMENT}" ]] || [[ -z "${AWS_REGION}" ]]; then
    log_error "Could not parse terraform.tfvars. Please ensure it contains:"
    log_error "  project_name = \"...\""
    log_error "  environment = \"...\""
    log_error "  aws_region = \"...\""
    exit 1
fi

log_success "project_name: ${PROJECT_NAME}"
log_success "environment: ${ENVIRONMENT}"
log_success "aws_region: ${AWS_REGION}"

# Get AWS account ID
log_info "Getting AWS account ID..."
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null || echo "")

if [[ -z "${ACCOUNT_ID}" ]]; then
    log_error "Could not get AWS account ID. Verify AWS credentials are configured."
    exit 1
fi
log_success "AWS account ID: ${ACCOUNT_ID}"

# Construct resource names
BACKEND_BUCKET="${BACKEND_PREFIX}-${PROJECT_NAME}-${ENVIRONMENT}-${ACCOUNT_ID}"
LOCK_TABLE="${BACKEND_PREFIX}-${PROJECT_NAME}-${ENVIRONMENT}-locks"
BACKEND_KEY="${PROJECT_NAME}/${ENVIRONMENT}/terraform.tfstate"

log_info ""
log_info "Backend Configuration:"
log_info "  Bucket: ${BACKEND_BUCKET}"
log_info "  Key: ${BACKEND_KEY}"
log_info "  DynamoDB Table: ${LOCK_TABLE}"
log_info "  Region: ${AWS_REGION}"
log_info ""

# Confirm before proceeding
read -p "Create backend resources? (y/N) " -n 1 -r
echo
if [[ ! ${REPLY} =~ ^[Yy]$ ]]; then
    log_warn "Cancelled."
    exit 0
fi

# ============================================================================
# Step 1: Create S3 Backend Bucket
# ============================================================================

log_info ""
log_info "Step 1/4: Creating S3 backend bucket..."

if aws s3api head-bucket --bucket "${BACKEND_BUCKET}" --region "${AWS_REGION}" 2>/dev/null; then
    log_warn "Bucket already exists: ${BACKEND_BUCKET}"
else
    log_info "Creating bucket: ${BACKEND_BUCKET}"
    
    if [[ "${AWS_REGION}" == "us-east-1" ]]; then
        # us-east-1 doesn't support LocationConstraint
        aws s3api create-bucket \
            --bucket "${BACKEND_BUCKET}" \
            --region "${AWS_REGION}" \
            --acl private \
            2>/dev/null
    else
        aws s3api create-bucket \
            --bucket "${BACKEND_BUCKET}" \
            --region "${AWS_REGION}" \
            --create-bucket-configuration LocationConstraint="${AWS_REGION}" \
            --acl private \
            2>/dev/null
    fi
    
    log_success "Bucket created: ${BACKEND_BUCKET}"
fi

# ============================================================================
# Step 2: Enable Versioning on S3 Bucket
# ============================================================================

log_info ""
log_info "Step 2/4: Enabling versioning on backend bucket..."

aws s3api put-bucket-versioning \
    --bucket "${BACKEND_BUCKET}" \
    --versioning-configuration Status=Enabled \
    --region "${AWS_REGION}" \
    2>/dev/null

log_success "Versioning enabled on bucket: ${BACKEND_BUCKET}"

# ============================================================================
# Step 3: Enable Server-Side Encryption on S3 Bucket
# ============================================================================

log_info ""
log_info "Step 3/4: Enabling encryption on backend bucket..."

aws s3api put-bucket-encryption \
    --bucket "${BACKEND_BUCKET}" \
    --server-side-encryption-configuration '{
        "Rules": [{
            "ApplyServerSideEncryptionByDefault": {
                "SSEAlgorithm": "AES256"
            },
            "BucketKeyEnabled": true
        }]
    }' \
    --region "${AWS_REGION}" \
    2>/dev/null

log_success "Server-side encryption enabled on bucket: ${BACKEND_BUCKET}"

# Block public access to backend bucket (critical for security)
log_info "Blocking public access to backend bucket..."

aws s3api put-public-access-block \
    --bucket "${BACKEND_BUCKET}" \
    --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true" \
    --region "${AWS_REGION}" \
    2>/dev/null

log_success "Public access blocked on backend bucket: ${BACKEND_BUCKET}"

# ============================================================================
# Step 4: Create DynamoDB Table for State Locks
# ============================================================================

log_info ""
log_info "Step 4/4: Creating DynamoDB table for state locks..."

# Check if table already exists
TABLE_EXISTS=$(aws dynamodb describe-table \
    --table-name "${LOCK_TABLE}" \
    --region "${AWS_REGION}" \
    2>/dev/null | grep -c "TableName" || echo "0")

if [[ "${TABLE_EXISTS}" -gt 0 ]]; then
    log_warn "DynamoDB table already exists: ${LOCK_TABLE}"
else
    log_info "Creating table: ${LOCK_TABLE}"
    
    aws dynamodb create-table \
        --table-name "${LOCK_TABLE}" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --billing-mode PAY_PER_REQUEST \
        --region "${AWS_REGION}" \
        2>/dev/null
    
    # Wait for table to be created
    log_info "Waiting for DynamoDB table to be active..."
    aws dynamodb wait table-exists \
        --table-name "${LOCK_TABLE}" \
        --region "${AWS_REGION}" \
        2>/dev/null
    
    log_success "DynamoDB table created and active: ${LOCK_TABLE}"
fi

# ============================================================================
# Summary and Next Steps
# ============================================================================

log_info ""
log_success "✓ Backend infrastructure created successfully!"
log_info ""
log_info "Next Steps:"
log_info "1. Update terraform/backend.tf with the following configuration:"
log_info ""
log_info "   terraform {"
log_info "     backend \"s3\" {"
log_info "       bucket         = \"${BACKEND_BUCKET}\""
log_info "       key            = \"${BACKEND_KEY}\""
log_info "       region         = \"${AWS_REGION}\""
log_info "       encrypt        = true"
log_info "       dynamodb_table = \"${LOCK_TABLE}\""
log_info "     }"
log_info "   }"
log_info ""
log_info "2. Run: cd terraform && terraform init"
log_info "   (Terraform will detect the backend config and ask to migrate state)"
log_info ""
log_info "3. Answer 'yes' when prompted to copy state to S3 backend"
log_info ""
log_info "Backend Resources Created:"
log_info "  • S3 Bucket: ${BACKEND_BUCKET}"
log_info "  • Versioning: Enabled"
log_info "  • Encryption: AES256"
log_info "  • Public Access: Blocked"
log_info "  • DynamoDB Table: ${LOCK_TABLE}"
log_info ""
log_info "Reference Documentation:"
log_info "  See BACKEND_SETUP_GUIDE.md for complete instructions"
log_info ""
