variable "aws_region" {
  description = "The AWS region where the resource will be deployed"
  type = string
  default = "us-east-1"
}

variable "app_name" {
  description = "Name of S3 bucket"
  type = string
  default = "portfolio"
}

variable "environment" {
  description = "Environment of app"
  type = string
  default = "prod"
}
