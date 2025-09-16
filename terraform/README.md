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
3. **Domain name** that you control (configured in variables.tf: `vphatfla.me`)
4. **External DNS provider** access to create CNAME records

## Bootstrap Process (Required for First Deployment)

### **Important**: State Bucket Bootstrap Required

Since the Terraform state bucket is managed by Terraform itself, you need to bootstrap it:

### Option 1: Terraform Bootstrap (Recommended)

```bash
# Step 1: Comment out the backend block in terraform.tf
# Edit terraform.tf and comment out lines 11-16:
# backend "s3" {
#     bucket  = "oppy-marser-terraform-state"
#     key     = "static-website/terraform.tfstate"
#     region  = "us-east-1"
#     encrypt = true
# }

# Step 2: Initialize with local state
terraform init

# Step 3: Create state bucket infrastructure
terraform apply -target=aws_s3_bucket.terraform_state \
    -target=aws_s3_bucket_versioning.terraform_state \
    -target=aws_s3_bucket_server_side_encryption_configuration.terraform_state \
    -target=aws_s3_bucket_public_access_block.terraform_state

# Step 4: Uncomment the backend block in terraform.tf

# Step 5: Migrate to remote state
terraform init -migrate-state

# Step 6: Continue with full deployment
terraform apply
```

### Option 2: Manual State Bucket (Alternative)

```bash
# Create state bucket manually
aws s3 mb s3://oppy-marser-terraform-state --region us-east-1
aws s3api put-bucket-versioning --bucket oppy-marser-terraform-state --versioning-configuration Status=Enabled
aws s3api put-public-access-block --bucket oppy-marser-terraform-state --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# Remove backend.tf to avoid resource conflicts
rm backend.tf

# Then proceed with normal terraform init && terraform apply
```

## Normal Deployment Process

### 1. Deploy Infrastructure

```bash
# Initialize Terraform (after bootstrap)
terraform init

# Review the deployment plan
terraform plan

# Deploy the infrastructure
terraform apply
```

### 2. Validate SSL Certificate

After deployment, add the DNS validation records to your DNS provider:

```bash
# Get certificate validation records
terraform output acm_certificate_domain_validation_options
```

Add the CNAME records shown in the output to your DNS provider.

### 3. Configure DNS

Point your domain to CloudFront:

```bash
# Get DNS configuration instructions
terraform output dns_configuration_instructions
```

Add the CNAME records to your DNS provider:
- **Type**: CNAME
- **Name**: vphatfla.me
- **Value**: [CloudFront domain from output]
- **TTL**: 300

### 4. Upload Website Files

```bash
# Upload your static files to S3
terraform output s3_upload_command

# Example:
aws s3 sync ./dist s3://your-bucket-name --delete
```

### 5. Access Your Website

Your website will be available at `https://vphatfla.me` once DNS propagates (usually 5-10 minutes).

## File Structure

```
terraform/
├── backend.tf                # State bucket infrastructure
├── main.tf                   # Core infrastructure resources
├── variables.tf             # Input variables and defaults
├── outputs.tf               # Output values and instructions
├── terraform.tf             # Provider and backend configuration
└── README.md                # This file
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

4. **Bootstrap fails**
   - Ensure backend block is commented out for initial deployment
   - Check AWS credentials and permissions

### Useful Commands

```bash
# Check S3 buckets
aws s3 ls

# Check certificate status
aws acm list-certificates --region us-east-1

# Check Terraform state
terraform state list

# Check specific resource
terraform state show aws_s3_bucket.main
```

## CI/CD Integration

This configuration works with the GitHub Actions workflow in `.github/workflows/terraform-deploy.yml`. The workflow:

1. **Validates** Terraform on PRs
2. **Applies** changes on main branch pushes
3. **Comments** with deployment results
4. **Requires** manual approval for production environment

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