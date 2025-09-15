# ========================================
# TERRAFORM STATE BACKEND INFRASTRUCTURE
# ========================================
# The S3 bucket for Terraform state storage is created automatically
# by the GitHub Actions workflow before running terraform init.
# This avoids the chicken-and-egg problem of needing Terraform state
# to create the Terraform state bucket.
#
# The state bucket is created with:
# - Versioning enabled
# - Server-side encryption (AES256)
# - Public access blocked
# - No DynamoDB table (single CI/CD process)
