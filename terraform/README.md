# Terraform AWS Static Website Infrastructure

This Terraform configuration deploys a cost-effective, secure static website hosting solution on AWS using S3, CloudFront, and ACM.

## Architecture

```
User/Browser → External DNS → CloudFront Distribution → S3 Private Bucket
                               ↓
                        ACM SSL Certificate
                               ↓
                     Origin Access Control (OAC)
```

## Features

- ✅ **Secure**: Private S3 bucket with Origin Access Control (OAC)
- ✅ **Fast**: CloudFront CDN with HTTP/2 and HTTP/3 support
- ✅ **Cost-effective**: ~$1-5/month for typical static sites
- ✅ **HTTPS**: Free SSL certificate via AWS Certificate Manager
- ✅ **Modern**: Uses 2025 best practices (OAC, SNI SSL, TLS 1.2+)
- ✅ **External DNS friendly**: Works with any DNS provider via CNAME

## Prerequisites

1. **AWS CLI configured** with appropriate permissions
2. **Terraform >= 1.0** installed
3. **Domain name** that you control
4. **External DNS provider** access to create CNAME records

## Quick Start

### 1. Setup Terraform Backend (One-time setup)

**Important**: The S3 bucket for Terraform state must exist before deploying the main infrastructure.

#### Option A: Manual Creation (Recommended for CI/CD)
```bash
# Create S3 bucket for state
aws s3 mb s3://oppy-marser-terraform-state --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
    --bucket oppy-marser-terraform-state \
    --versioning-configuration Status=Enabled

# Block public access
aws s3api put-public-access-block \
    --bucket oppy-marser-terraform-state \
    --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# DynamoDB table for locking not needed (single CI/CD process)
```

#### Option B: Deploy Backend Resources First
```bash
# Temporarily comment out the backend block in terraform.tf
# Deploy backend infrastructure
terraform apply -target=aws_s3_bucket.terraform_state

# Uncomment backend block and re-initialize
terraform init -migrate-state
```

### 2. Configure Variables

```bash
# Copy and customize the example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your domain and preferences
nano terraform.tfvars
```

**Required Variables:**
- `domain_name`: Your domain (e.g., "mywebsite.com")

### 3. Deploy Infrastructure

```bash
# Initialize Terraform (connects to remote state)
terraform init

# Review the deployment plan
terraform plan

# Deploy the infrastructure
terraform apply
```

### 4. Validate SSL Certificate

After deployment, add the DNS validation records to your DNS provider:

```bash
# Get certificate validation records
terraform output acm_certificate_domain_validation_options
```

Add the CNAME records shown in the output to your DNS provider.

### 5. Configure DNS

Point your domain to CloudFront:

```bash
# Get DNS configuration instructions
terraform output dns_configuration_instructions
```

Add the CNAME records to your DNS provider:
- **Type**: CNAME
- **Name**: yourdomain.com
- **Value**: [CloudFront domain from output]
- **TTL**: 300

### 6. Upload Website Files

```bash
# Upload your static files to S3
terraform output s3_upload_command

# Example:
aws s3 sync ./dist s3://your-bucket-name --delete
```

### 7. Access Your Website

Your website will be available at `https://yourdomain.com` once DNS propagates (usually 5-10 minutes).

## File Structure

```
terraform/
├── main.tf                     # Core infrastructure resources
├── variables.tf               # Input variables and validation
├── outputs.tf                # Output values and instructions
├── locals.tf                 # Local values and naming conventions
├── terraform.tf              # Provider and version requirements
├── terraform.tfvars.example  # Example configuration
└── README.md                 # This file
```

## Resource Overview

| Resource | Purpose | Cost Impact |
|----------|---------|-------------|
| **S3 Bucket** | Static file storage | ~$0.023/GB/month |
| **CloudFront** | Global CDN | 1TB free tier, then ~$0.085/GB |
| **ACM Certificate** | Free SSL | $0 |
| **Origin Access Control** | Security | $0 |

**Total Cost**: ~$1-5/month for typical static websites

## Security Features

- **Private S3 bucket** - No public access
- **Origin Access Control (OAC)** - Modern replacement for OAI
- **HTTPS enforcement** - All HTTP traffic redirected to HTTPS
- **TLS 1.2+ minimum** - Modern encryption standards
- **Security headers** - AWS managed security headers policy

## Customization

### Custom Error Pages (SPA Support)

For Single Page Applications, the default configuration redirects 404 errors to `index.html`. Customize in `terraform.tfvars`:

```hcl
custom_error_responses = [
  {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 300
  }
]
```

### Price Class Options

Control CloudFront global distribution and costs:

- `PriceClass_100`: North America and Europe (cheapest)
- `PriceClass_200`: Add Asia, Middle East, Africa
- `PriceClass_All`: All edge locations (most expensive)

### Cache Configuration

Adjust caching behavior in `terraform.tfvars`:

```hcl
cache_default_ttl = 86400    # 24 hours
cache_max_ttl     = 31536000 # 1 year
```

## Operations

### Update Website Content

```bash
# Upload new files
aws s3 sync ./dist s3://$(terraform output -raw s3_bucket_name) --delete

# Invalidate CloudFront cache
terraform output -raw cloudfront_invalidation_command | bash
```

### Monitor Resources

Key CloudWatch metrics to monitor:
- **S3**: Bucket size, request count
- **CloudFront**: Cache hit ratio, origin latency, error rates
- **ACM**: Certificate expiration (auto-renewed)

### Backup and Recovery

- **S3 Versioning**: Enabled by default
- **Terraform State**: Consider using remote backend for production
- **Configuration**: Version control this Terraform code

## Troubleshooting

### Common Issues

1. **Certificate validation fails**
   - Ensure DNS records are added correctly
   - Wait up to 30 minutes for validation

2. **403 errors from CloudFront**
   - Check S3 bucket policy
   - Verify OAC configuration

3. **Domain not working**
   - Verify CNAME records in DNS
   - Check CloudFront aliases configuration

4. **Files not updating**
   - Invalidate CloudFront cache
   - Check S3 upload was successful

### Useful Commands

```bash
# Check CloudFront distribution status
aws cloudfront get-distribution --id $(terraform output -raw cloudfront_distribution_id)

# List S3 bucket contents
aws s3 ls s3://$(terraform output -raw s3_bucket_name) --recursive

# Check certificate status
aws acm describe-certificate --certificate-arn $(terraform output -raw acm_certificate_arn) --region us-east-1
```

## Cleanup

To destroy all resources:

```bash
# WARNING: This will delete your website and all data
terraform destroy
```

## Support

- [AWS CloudFront Documentation](https://docs.aws.amazon.com/cloudfront/)
- [AWS S3 Documentation](https://docs.aws.amazon.com/s3/)
- [AWS Certificate Manager Documentation](https://docs.aws.amazon.com/acm/)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## License

This Terraform configuration is provided as-is under the MIT license.