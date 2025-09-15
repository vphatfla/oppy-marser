# ========================================
# S3 OUTPUTS
# ========================================

output "s3_bucket_name" {
    description = "Name of the S3 bucket"
    value       = aws_s3_bucket.main.id
}

output "s3_bucket_arn" {
    description = "ARN of the S3 bucket"
    value       = aws_s3_bucket.main.arn
}

output "s3_bucket_domain_name" {
    description = "Regional domain name of the S3 bucket"
    value       = aws_s3_bucket.main.bucket_regional_domain_name
}

output "s3_upload_command" {
    description = "AWS CLI command to upload files to S3 bucket"
    value       = "aws s3 sync ./dist s3://${aws_s3_bucket.main.id} --delete"
}

# ========================================
# CLOUDFRONT OUTPUTS
# ========================================

output "cloudfront_distribution_id" {
    description = "ID of the CloudFront distribution"
    value       = aws_cloudfront_distribution.main.id
}

output "cloudfront_distribution_arn" {
    description = "ARN of the CloudFront distribution"
    value       = aws_cloudfront_distribution.main.arn
}

output "cloudfront_domain_name" {
    description = "Domain name of the CloudFront distribution"
    value       = aws_cloudfront_distribution.main.domain_name
}

output "cloudfront_hosted_zone_id" {
    description = "CloudFront hosted zone ID for Route53 alias records"
    value       = aws_cloudfront_distribution.main.hosted_zone_id
}

output "cloudfront_invalidation_command" {
    description = "AWS CLI command to invalidate CloudFront cache"
    value       = "aws cloudfront create-invalidation --distribution-id ${aws_cloudfront_distribution.main.id} --paths '/*'"
}

# ========================================
# ACM CERTIFICATE OUTPUTS
# ========================================

output "acm_certificate_arn" {
    description = "ARN of the ACM certificate"
    value       = aws_acm_certificate.main.arn
}

output "acm_certificate_domain_validation_options" {
    description = "Domain validation options for ACM certificate"
    value       = aws_acm_certificate.main.domain_validation_options
    sensitive   = false
}

# ========================================
# DOMAIN CONFIGURATION OUTPUTS
# ========================================

output "website_url" {
    description = "Website URL (HTTPS)"
    value       = "https://${var.domain_name}"
}

output "www_website_url" {
    description = "Website URL with www subdomain (if enabled)"
    value       = var.enable_www_subdomain ? "https://www.${var.domain_name}" : "Not configured"
}

output "dns_configuration_instructions" {
    description = "Instructions for configuring DNS with external provider"
    value = {
        primary_domain = {
            type  = "CNAME"
            name  = var.domain_name
            value = aws_cloudfront_distribution.main.domain_name
            ttl   = 300
        }
        www_domain = var.enable_www_subdomain ? {
            type  = "CNAME"
            name  = "www.${var.domain_name}"
            value = aws_cloudfront_distribution.main.domain_name
            ttl   = 300
        } : "Not configured"
        certificate_validation = "Add the following DNS records to validate the SSL certificate"
    }
}

# ========================================
# DEPLOYMENT INFORMATION
# ========================================

output "deployment_summary" {
    description = "Summary of deployed infrastructure"
    value = {
        project_name            = var.project_name
        environment             = var.environment
        domain_name             = var.domain_name
        s3_bucket               = aws_s3_bucket.main.id
        cloudfront_distribution = aws_cloudfront_distribution.main.id
        ssl_certificate         = aws_acm_certificate.main.arn
        website_url             = "https://${var.domain_name}"
        estimated_monthly_cost  = "$1-5 USD for typical traffic"
    }
}