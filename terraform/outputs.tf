output "s3_bucket_name" {
  description = "Name of the S3 bucket hosting the static website"
  value       = aws_s3_bucket.website.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.website.arn
}

output "s3_bucket_region" {
  description = "AWS region where S3 bucket is located"
  value       = aws_s3_bucket.website.region
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name (your website URL)"
  value       = aws_cloudfront_distribution.website.domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID (used for cache invalidation)"
  value       = aws_cloudfront_distribution.website.id
}

output "cloudfront_distribution_arn" {
  description = "ARN of the CloudFront distribution"
  value       = aws_cloudfront_distribution.website.arn
}

output "website_url" {
  description = "Complete URL of the deployed website"
  value       = "https://${aws_cloudfront_distribution.website.domain_name}"
}

output "github_actions_role_arn" {
  description = "ARN of IAM role for GitHub Actions deployment"
  value       = try(aws_iam_role.github_actions[0].arn, "Not configured - create manually if using GitHub Actions")
}

output "deployment_info" {
  description = "Summary of deployment information"
  value = {
    bucket_name          = aws_s3_bucket.website.id
    cloudfront_url       = "https://${aws_cloudfront_distribution.website.domain_name}"
    distribution_id      = aws_cloudfront_distribution.website.id
    region               = var.aws_region
    environment          = var.environment
    https_enforced       = true
    oai_configured       = true
    versioning_enabled   = var.enable_versioning
  }
}
