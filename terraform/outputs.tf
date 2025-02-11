output "portfolio_bucket_name" {
  description = "Name of the s3 bucket"
  value       = aws_s3_bucket.website
}

output "portfolio_website_endpoint" {
  description = "EndPoint for the portfolio"
  value       = aws_s3_bucket_website_configuration.website.website_endpoint
}

output "ecr_repository_url" {
  value = aws_ecr_repository.portfolio_app.repository_url
}

output "alb_dns_name" {
  value = aws_lb.portfolio_app.dns_name
}
