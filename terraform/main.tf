terraform {
  required_version = ">=1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket = "terraform-state-portfolio"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

