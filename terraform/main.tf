# Configure AWS Provider
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.81.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

# ============================================================================
# S3 Bucket for Static Website Hosting
# ============================================================================

resource "aws_s3_bucket" "website" {
  bucket = local.bucket_name

  tags = {
    Name        = "${var.project_name}-website-bucket"
    Description = "S3 bucket for static portfolio website"
  }
}

# Enable versioning for safety and rollback capability
resource "aws_s3_bucket_versioning" "website" {
  bucket = aws_s3_bucket.website.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

# Enable server-side encryption for security
resource "aws_s3_bucket_server_side_encryption_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block all public access to S3 bucket (CloudFront OAI will handle access)
resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable static website hosting (optional - used for error handling)
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html" # Route 404s to index.html for SPA support
  }

  depends_on = [aws_s3_bucket_public_access_block.website]
}

# ============================================================================
# CloudFront Origin Access Identity (OAI)
# ============================================================================

resource "aws_cloudfront_origin_access_identity" "website" {
  comment = local.oai_comment
}

# S3 bucket policy - Allow CloudFront OAI to read objects
resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudFrontAccess"
        Effect = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.website.iam_arn
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.website.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.website]
}

# ============================================================================
# CloudFront Distribution for CDN and HTTPS
# ============================================================================

resource "aws_cloudfront_distribution" "website" {
  origin {
    domain_name = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.website.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  http_version        = "http2and3"

  # Default cache behavior for all objects
  default_cache_behavior {
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    compress               = true
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600  # 1 hour
    max_ttl                = 86400 # 24 hours
  }

  # Custom error response - route 404 to index.html for SPA support
  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 300
  }

  # Security headers and restrictions
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name        = "${var.project_name}-cloudfront-distribution"
    Description = "CloudFront CDN for portfolio website"
  }

  depends_on = [aws_s3_bucket_policy.website]
}

# ============================================================================
# IAM Role and Policy for GitHub Actions Deployment (Optional)
# ============================================================================

# Create IAM role for GitHub Actions (commented out - uncomment if using GitHub Actions)
resource "aws_iam_role" "github_actions" {
  count = 0 # Set to 1 to enable GitHub Actions role

  name = "${var.project_name}-github-actions-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-github-actions-role"
  }
}

# IAM policy for S3 and CloudFront access
resource "aws_iam_role_policy" "github_actions_policy" {
  count = 0 # Set to 1 to enable GitHub Actions policy

  name = "${var.project_name}-github-actions-policy"
  role = aws_iam_role.github_actions[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3Access"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketVersioning"
        ]
        Resource = [
          aws_s3_bucket.website.arn,
          "${aws_s3_bucket.website.arn}/*"
        ]
      },
      {
        Sid    = "CloudFrontInvalidation"
        Effect = "Allow"
        Action = [
          "cloudfront:CreateInvalidation",
          "cloudfront:GetDistribution",
          "cloudfront:GetDistributionConfig"
        ]
        Resource = aws_cloudfront_distribution.website.arn
      }
    ]
  })
}

# ============================================================================
# Outputs Summary
# ============================================================================

output "infrastructure_summary" {
  value = "✅ Infrastructure deployed successfully!\nWebsite URL: https://${aws_cloudfront_distribution.website.domain_name}\nS3 Bucket: ${aws_s3_bucket.website.id}\nDistribution ID: ${aws_cloudfront_distribution.website.id}"
}
