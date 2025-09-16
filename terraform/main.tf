# ========================================
# S3 BUCKET FOR STATIC WEBSITE HOSTING
# ========================================

resource "aws_s3_bucket" "main" {
  bucket        = "${var.project_name}-${var.environment}-static-website-${random_id.bucket_suffix.hex}"
  force_destroy = var.s3_bucket_force_destroy

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-${var.environment}-static-website-bucket"
    Type        = "StaticWebsiteStorage"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "StaticWebsite"
  })
}

# Random ID for S3 bucket naming to ensure global uniqueness
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = var.enable_s3_versioning ? "Enabled" : "Disabled"
  }
}

# S3 bucket server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# Block all public access to S3 bucket
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 bucket ownership controls
resource "aws_s3_bucket_ownership_controls" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }

  depends_on = [aws_s3_bucket_public_access_block.main]
}

# ========================================
# ACM CERTIFICATE FOR HTTPS
# ========================================

resource "aws_acm_certificate" "main" {
  domain_name               = var.domain_name
  subject_alternative_names = var.enable_www_subdomain ? ["www.${var.domain_name}"] : []
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-${var.environment}-ssl-certificate"
    Type        = "SSLCertificate"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "StaticWebsite"
  })
}

# Certificate validation - waits for DNS validation before proceeding
resource "aws_acm_certificate_validation" "main" {
  certificate_arn = aws_acm_certificate.main.arn

  # Terraform will wait until certificate is validated
  timeouts {
    create = "10m"
  }
}

# ========================================
# CLOUDFRONT ORIGIN ACCESS CONTROL (OAC)
# ========================================

resource "aws_cloudfront_origin_access_control" "main" {
  name                              = "${var.project_name}-${var.environment}-s3-oac"
  description                       = "Origin Access Control for ${var.project_name}-${var.environment} S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# ========================================
# CLOUDFRONT DISTRIBUTION
# ========================================

resource "aws_cloudfront_distribution" "main" {
  depends_on = [
    aws_s3_bucket.main,
    aws_cloudfront_origin_access_control.main
  ]

  # Origin configuration
  origin {
    domain_name              = aws_s3_bucket.main.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.main.id
    origin_id                = "${var.project_name}-${var.environment}-s3-origin"
  }

  # Distribution settings
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.default_root_object
  # aliases             = var.enable_www_subdomain ? [var.domain_name, "www.${var.domain_name}"] : [var.domain_name]
  price_class         = var.cloudfront_price_class
  http_version        = "http2and3"

  # Default cache behavior
  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "${var.project_name}-${var.environment}-s3-origin"
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    # Modern cache policy - optimized for static websites
    cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # AWS Managed CachingOptimized policy

    # Response headers policy for security
    response_headers_policy_id = "5cc3b908-e619-4b99-88e5-2cf7f45965bd" # AWS Managed SecurityHeadersPolicy
  }

  # Custom error responses for SPA support
  dynamic "custom_error_response" {
    for_each = var.custom_error_responses
    content {
      error_code            = custom_error_response.value.error_code
      response_code         = custom_error_response.value.response_code
      response_page_path    = custom_error_response.value.response_page_path
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl
    }
  }

  # SSL certificate configuration
  viewer_certificate {
    # acm_certificate_arn            = aws_acm_certificate_validation.main.certificate_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
    cloudfront_default_certificate = true
  }

  # Geographic restrictions (none by default)
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = merge(var.additional_tags, {
    Name        = "${var.project_name}-${var.environment}-cloudfront-distribution"
    Type        = "CDN"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "StaticWebsite"
  })
}

# ========================================
# S3 BUCKET POLICY FOR CLOUDFRONT ACCESS
# ========================================

resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipalReadOnly"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.main.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.main.arn
          }
        }
      }
    ]
  })

  depends_on = [
    aws_cloudfront_distribution.main,
    aws_s3_bucket_ownership_controls.main
  ]
}
