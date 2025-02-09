output "portfolio_bucket_name" {
  description = "Name of the s3 bucket"
  value = aws_s3_bucket.portfolio.id
}

output "portfolio_website_endpoint" {
  description = "EndPoint for the portfolio"
  value = aws_s3_bucket_website_configuration.portfolio.website_endpoint
}

