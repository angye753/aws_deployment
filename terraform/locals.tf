# Local values for consistent naming and configuration

locals {
  # Generate unique bucket name with timestamp
  bucket_name = "${var.project_name}-${var.environment}-${data.aws_caller_identity.current.account_id}"

  # Common tags applied to all resources
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
    }
  )

  # CloudFront origin ID
  s3_origin_id = "${var.project_name}-${var.environment}-origin"

  # OAI description
  oai_comment = "OAI for ${var.project_name} portfolio website in ${var.environment}"
}

# Get current AWS account ID for naming
data "aws_caller_identity" "current" {}
