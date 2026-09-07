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
# PIGGY-TRACKING INTEGRATION
# ========================================
# piggy-tracking rides on this distribution instead of getting its own, so
# both apps stay reachable at vphatfla.me at all times — see
# ~/workplace/piggy-tracking/terraform/README.md for the full picture. This
# stack owns the distribution (and this ACM cert, and the domain's DNS);
# piggy-tracking's Terraform only ever reads this stack's outputs, never the
# other way around for anything but the two blocks below.

# Read-only: piggy-tracking's stack must be applied first so these outputs
# exist. See piggy-tracking/terraform/README.md for the required apply order.
data "terraform_remote_state" "piggy_tracking" {
  backend = "s3"
  config = {
    bucket = "piggy-tracking-terraform-state"
    key    = "infra/terraform.tfstate"
    region = "us-east-1"
  }
}

# Looked up by name rather than copied as raw hex ids (unlike the two literal
# ids in default_cache_behavior below, which predate this change and are
# left as-is) — safer than trusting an id transcribed by hand.
data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_response_headers_policy" "security_headers" {
  name = "Managed-SecurityHeadersPolicy"
}

# The API needs cookies/headers/query strings forwarded to the origin — the
# cache policy alone only controls the cache key, not what reaches origin.
data "aws_cloudfront_origin_request_policy" "all_viewer" {
  name = "Managed-AllViewer"
}

# Rewrites a URI ending in "/" (or with no file extension at all — covers
# the bare /app/piggy-tracking with no trailing slash, the URL a user
# actually types/bookmarks) to append index.html. Needed because
# default_root_object only covers the distribution's actual root (/) — a
# request to /app/piggy-tracking/ wouldn't otherwise resolve through the S3
# REST origin the way S3's own static-website-hosting mode would. No
# origin_path is set on the S3 origin below, so the full viewer path
# (including /app/piggy-tracking) is what's requested from S3 — the
# frontend-deploy workflow syncs the build to that same key prefix in the
# bucket, not to bucket root. piggy-tracking has no client-side router, so
# this one rule is enough — no catch-all SPA rewrite needed.
resource "aws_cloudfront_function" "piggy_tracking_index_rewrite" {
  name    = "piggy-tracking-index-rewrite"
  runtime = "cloudfront-js-2.0"
  comment = "Append index.html to a directory-style URI"
  publish = true
  code    = <<-EOT
    function handler(event) {
      var request = event.request;
      var uri = request.uri;
      if (uri.endsWith('/')) {
        request.uri += 'index.html';
      } else if (!uri.includes('.')) {
        request.uri += '/index.html';
      }
      return request;
    }
  EOT
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

  # piggy-tracking's frontend build — same OAC, this distribution is still
  # the only one that can read it (see the bucket policy in
  # piggy-tracking/terraform/main.tf, which scopes to *this* resource's arn).
  origin {
    domain_name              = data.terraform_remote_state.piggy_tracking.outputs.s3_bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.main.id
    origin_id                = "piggy-tracking-s3-origin"
  }

  # piggy-tracking's backend API. HTTP to the origin is fine here — traffic
  # stays on the AWS backbone, and the origin's own security group only
  # accepts inbound from CloudFront's published IP ranges (see
  # piggy-tracking/terraform/main.tf's aws_security_group.backend). The
  # viewer-facing side is still HTTPS-only via viewer_certificate below.
  origin {
    domain_name = data.terraform_remote_state.piggy_tracking.outputs.backend_eip_public_dns
    origin_id   = "piggy-tracking-api-origin"

    custom_origin_config {
      http_port                = 3000
      https_port               = 443
      origin_protocol_policy   = "http-only"
      origin_ssl_protocols     = ["TLSv1.2"]
      origin_keepalive_timeout = 5
      origin_read_timeout      = 30
    }
  }

  # Distribution settings
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.default_root_object
  aliases             = var.enable_www_subdomain ? [var.domain_name, "www.${var.domain_name}"] : [var.domain_name]
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

  # piggy-tracking's frontend static assets. Two behaviors, not one:
  # "/app/piggy-tracking/*" only matches paths that already have the
  # trailing slash - CloudFront's wildcard match requires the literal "/"
  # before the "*" to be present, so a bare "/app/piggy-tracking" (no
  # trailing slash - the URL someone actually types or bookmarks) doesn't
  # match it at all and falls through to the default behavior above, i.e.
  # oppy-marser's own origin. Confirmed the hard way (403 from the wrong
  # bucket). The exact-match behavior below covers that one path literally,
  # identical settings otherwise.
  ordered_cache_behavior {
    path_pattern               = "/app/piggy-tracking"
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cached_methods             = ["GET", "HEAD"]
    target_origin_id           = "piggy-tracking-s3-origin"
    compress                   = true
    viewer_protocol_policy     = "redirect-to-https"
    cache_policy_id            = data.aws_cloudfront_cache_policy.caching_optimized.id
    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.security_headers.id

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.piggy_tracking_index_rewrite.arn
    }
  }

  ordered_cache_behavior {
    path_pattern               = "/app/piggy-tracking/*"
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cached_methods             = ["GET", "HEAD"]
    target_origin_id           = "piggy-tracking-s3-origin"
    compress                   = true
    viewer_protocol_policy     = "redirect-to-https"
    cache_policy_id            = data.aws_cloudfront_cache_policy.caching_optimized.id
    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.security_headers.id

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.piggy_tracking_index_rewrite.arn
    }
  }

  # piggy-tracking's backend API — never cached, everything forwarded.
  ordered_cache_behavior {
    path_pattern             = "/api/*"
    allowed_methods          = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods           = ["GET", "HEAD"]
    target_origin_id         = "piggy-tracking-api-origin"
    compress                 = true
    viewer_protocol_policy   = "redirect-to-https"
    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer.id
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
    acm_certificate_arn            = aws_acm_certificate_validation.main.certificate_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
    cloudfront_default_certificate = false
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
