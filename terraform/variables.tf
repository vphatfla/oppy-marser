# Project Configuration
variable "project_name" {
    description = "Name of the project - used for resource naming"
    type        = string
    default     = "oppy-marser"
}

variable "environment" {
    description = "Environment name (dev, staging, prod)"
    type        = string
    default     = "prod"
}

# AWS Configuration
variable "aws_region" {
    description = "AWS region for resources (except ACM certificate)"
    type        = string
    default     = "us-east-1"
}

# Domain Configuration
variable "domain_name" {
    description = "Primary domain name for the website"
    type        = string
    default     = "vphatfla.me"
}

variable "enable_www_subdomain" {
    description = "Whether to include www subdomain in certificate"
    type        = bool
    default     = true
}

# S3 Configuration
variable "s3_bucket_force_destroy" {
    description = "Allow Terraform to destroy S3 bucket with objects (use with caution)"
    type        = bool
    default     = false
}

variable "enable_s3_versioning" {
    description = "Enable S3 bucket versioning"
    type        = bool
    default     = true
}

# CloudFront Configuration
variable "cloudfront_price_class" {
    description = "CloudFront price class"
    type        = string
    default     = "PriceClass_100"
    validation {
        condition     = contains(["PriceClass_All", "PriceClass_200", "PriceClass_100"], var.cloudfront_price_class)
        error_message = "Price class must be PriceClass_All, PriceClass_200, or PriceClass_100."
    }
}

variable "default_root_object" {
    description = "Default root object for CloudFront"
    type        = string
    default     = "index.html"
}

variable "custom_error_responses" {
    description = "Custom error responses for CloudFront"
    type = list(object({
        error_code            = number
        response_code         = number
        response_page_path    = string
        error_caching_min_ttl = number
    }))
    default = [
        {
            error_code            = 404
            response_code         = 200
            response_page_path    = "/index.html"
            error_caching_min_ttl = 300
        }
    ]
}

# Cache Configuration
variable "cache_default_ttl" {
    description = "Default TTL for CloudFront cache"
    type        = number
    default     = 86400 # 24 hours
}

variable "cache_max_ttl" {
    description = "Maximum TTL for CloudFront cache"
    type        = number
    default     = 432000 # 5 days
}

# Tags
variable "additional_tags" {
    description = "Additional tags to apply to all resources"
    type        = map(string)
    default     = {}
}