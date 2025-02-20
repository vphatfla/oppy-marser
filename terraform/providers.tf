provider "aws" {
  region = var.aws_region
  alias  = "us-east-1"
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.app_name
      ManagedBy   = "Terraform"
    }
  }
}
