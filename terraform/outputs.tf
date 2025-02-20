output "portfolio_bucket_name" {
  description = "Name of the s3 bucket"
  value       = aws_s3_bucket.website
}

output "portfolio_website_endpoint" {
  description = "EndPoint for the portfolio"
  value       = aws_s3_bucket_website_configuration.website.website_endpoint
}

output "vpc_id" {
  description = "VPC IP"
  value       = aws_vpc.main.id
}

output "pubic_subnet_id" {
  description = "VPC's Public Subnet ID"
  value       = aws_subnet.public.id
}

output "ec2_public_ip" {
  value = aws_instance.app.id
}

output "ec2_public_dns" {
  value = aws_instance.app.public_dns
}

output "cloudfront_dns" {
  value = aws_cloudfront_distribution.main.domain_name
}
