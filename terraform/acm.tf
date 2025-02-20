resource "aws_acm_certificate" "portfolio_cert" {
  provider = aws.us-east-1

  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = {
    Name = "${var.app_name}-cert"
  }

  lifecycle {
    create_before_destroy = true
  }
}
