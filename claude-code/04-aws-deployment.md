# AWS Static Website Deployment Guide

## Architecture Overview

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   User/Browser  │───▶│   External DNS   │───▶│   CloudFront    │
│                 │    │   Provider       │    │   Distribution  │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                ▲                        │
                                │                        │
                          CNAME Record                   │
                      (yourdomain.com →                  │
                       xxxxx.cloudfront.net)             │
                                                         ▼
                                               ┌─────────────────┐
                                               │       S3        │
                                               │   Private       │
                                               │    Bucket       │
                                               └─────────────────┘
                                                         ▲
                                                         │
                                                Origin Access Control
                                                    (OAC)
```

## Recommended Deployment Architecture

### Core Components:
1. **Amazon S3** - Static file storage (private bucket)
2. **Amazon CloudFront** - Global CDN with HTTPS termination
3. **AWS Certificate Manager (ACM)** - Free SSL certificate
4. **Origin Access Control (OAC)** - Secure bucket access
5. **External DNS Provider** - Domain management via CNAME

## Implementation Steps

### Step 1: Create S3 Bucket

```bash
# Create private S3 bucket
aws s3 mb s3://your-static-website-bucket --region us-east-1

# Upload static files
aws s3 sync ./dist s3://your-static-website-bucket

# Ensure bucket is private (no public access)
aws s3api put-public-access-block \
    --bucket your-static-website-bucket \
    --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
```

### Step 2: Request SSL Certificate via ACM

```bash
# Request certificate in us-east-1 (required for CloudFront)
aws acm request-certificate \
    --domain-name yourdomain.com \
    --subject-alternative-names *.yourdomain.com \
    --validation-method DNS \
    --region us-east-1
```

**Important**: You must validate the certificate by adding DNS records provided by ACM to your external DNS provider.

### Step 3: Create Origin Access Control (OAC)

```json
{
    "Name": "S3-OAC-for-static-website",
    "Description": "OAC for static website S3 bucket",
    "OriginAccessControlConfig": {
        "Name": "S3-OAC-for-static-website",
        "Description": "OAC for static website S3 bucket",
        "SigningBehavior": "always",
        "SigningProtocol": "sigv4",
        "OriginAccessControlOriginType": "s3"
    }
}
```

### Step 4: Create CloudFront Distribution

```json
{
    "CallerReference": "static-website-2025",
    "Comment": "Static website distribution",
    "DefaultCacheBehavior": {
        "TargetOriginId": "S3-your-static-website-bucket",
        "ViewerProtocolPolicy": "redirect-to-https",
        "Compress": true,
        "ForwardedValues": {
            "QueryString": false,
            "Cookies": {
                "Forward": "none"
            }
        }
    },
    "Origins": {
        "Quantity": 1,
        "Items": [
            {
                "Id": "S3-your-static-website-bucket",
                "DomainName": "your-static-website-bucket.s3.us-east-1.amazonaws.com",
                "S3OriginConfig": {
                    "OriginAccessIdentity": ""
                },
                "OriginAccessControlId": "your-oac-id"
            }
        ]
    },
    "Aliases": {
        "Quantity": 1,
        "Items": ["yourdomain.com"]
    },
    "ViewerCertificate": {
        "ACMCertificateArn": "arn:aws:acm:us-east-1:account:certificate/cert-id",
        "SSLSupportMethod": "sni-only",
        "MinimumProtocolVersion": "TLSv1.2_2021"
    },
    "DefaultRootObject": "index.html",
    "Enabled": true
}
```

### Step 5: Update S3 Bucket Policy

```json
{
    "Version": "2012-10-17",
    "Statement": {
        "Sid": "AllowCloudFrontServicePrincipalReadOnly",
        "Effect": "Allow",
        "Principal": {
            "Service": "cloudfront.amazonaws.com"
        },
        "Action": "s3:GetObject",
        "Resource": "arn:aws:s3:::your-static-website-bucket/*",
        "Condition": {
            "StringEquals": {
                "AWS:SourceArn": "arn:aws:cloudfront::YOUR_AWS_ACCOUNT_ID:distribution/YOUR_DISTRIBUTION_ID"
            }
        }
    }
}
```

### Step 6: Configure External DNS

Add CNAME record to your DNS provider:

```
Type: CNAME
Name: yourdomain.com (or www)
Value: xxxxx.cloudfront.net
TTL: 300
```

## Security Best Practices (2025)

### 1. Origin Access Control (OAC) - Not OAI
- **Use OAC instead of legacy OAI** for enhanced security
- Supports all AWS regions and SSE-KMS encryption
- Short-term credentials with frequent rotation

### 2. HTTPS Configuration
- **Redirect HTTP to HTTPS** for all traffic
- Use **SNI SSL** (free) instead of dedicated IP ($600/month)
- Minimum TLS version 1.2

### 3. S3 Security
- **Private bucket only** - no public access
- **Bucket owner enforced** object ownership
- Access only via CloudFront OAC

## Cost Optimization

### Monthly Cost Breakdown:
- **S3 Storage**: ~$0.023/GB/month
- **CloudFront**: 1TB free tier, then ~$0.085/GB
- **ACM Certificate**: FREE
- **DNS requests**: Varies by provider
- **Total**: ~$1-5/month for typical static sites

### Cost Savings:
- ✅ Free SSL via ACM (saves $100+/year)
- ✅ SNI SSL instead of dedicated IP (saves $600/month)
- ✅ CloudFront caching reduces S3 requests
- ✅ Global edge locations improve performance

## Deployment Script

```bash
#!/bin/bash

# Variables
BUCKET_NAME="your-static-website-bucket"
DOMAIN="yourdomain.com"
REGION="us-east-1"

# 1. Create and configure S3 bucket
aws s3 mb s3://$BUCKET_NAME --region $REGION
aws s3api put-public-access-block --bucket $BUCKET_NAME \
    --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# 2. Upload static files
aws s3 sync ./dist s3://$BUCKET_NAME

# 3. Request ACM certificate
CERT_ARN=$(aws acm request-certificate \
    --domain-name $DOMAIN \
    --validation-method DNS \
    --region $REGION \
    --query 'CertificateArn' \
    --output text)

echo "Certificate ARN: $CERT_ARN"
echo "Please validate certificate via DNS before proceeding..."

# 4. Create OAC (manual step - save the ID)
echo "Create OAC via AWS Console and note the ID"

# 5. Create CloudFront distribution (manual step due to complexity)
echo "Create CloudFront distribution with the certificate and OAC"

# 6. Update bucket policy with distribution ARN
echo "Update S3 bucket policy with CloudFront distribution ARN"
```

## Monitoring and Maintenance

### CloudWatch Metrics to Monitor:
- **S3**: Number of objects, bucket size
- **CloudFront**: Cache hit ratio, origin latency, error rates
- **ACM**: Certificate expiration (auto-renewed)

### Automated Deployment:
Consider using **AWS CDK** or **Terraform** for infrastructure as code:

```typescript
// AWS CDK example
const distribution = new cloudfront.Distribution(this, 'StaticWebsite', {
  defaultBehavior: {
    origin: new origins.S3Origin(bucket, {
      originAccessIdentity: oac,
    }),
    viewerProtocolPolicy: ViewerProtocolPolicy.REDIRECT_TO_HTTPS,
  },
  domainNames: ['yourdomain.com'],
  certificate: acmCertificate,
});
```

## Troubleshooting

### Common Issues:
1. **Certificate validation timeout**: Ensure DNS records are correctly added
2. **403 errors**: Check OAC configuration and S3 bucket policy
3. **Custom domain not working**: Verify CNAME record and certificate
4. **Cache issues**: Use CloudFront cache invalidation

### Cache Invalidation:
```bash
# Invalidate CloudFront cache after deployment
aws cloudfront create-invalidation \
    --distribution-id YOUR_DISTRIBUTION_ID \
    --paths "/*"
```

This architecture provides a secure, cost-effective, and scalable solution for hosting static websites on AWS with HTTPS support and external domain management.