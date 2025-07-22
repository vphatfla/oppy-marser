# Point Cloudfront distribution to an EC2 instance using its  public DNS

## Purpose

Minimize the cost of running services on AWS by eliminating the use of elastic IPv4, load balancer, NAT, ...

Every user has 750 hours free of charge when using *public ipv4* (not elastic), hence, this method might reduce the cost of app hosting when there is no need for Load Balancer and/or NAT.

This is a trick to reduce cost, not a standard/recommended way to host important, secured applications.

## Terraform

    # cloudfront.tf

    locals {
        s3_origin_id  = "S3-${aws_s3_bucket.website.bucket}"
        ec2_origin_id = "EC2-${aws_instance.app.id}"
    }

    resource "aws_cloudfront_distribution" "main" {

        ...

        origin {
            domain_name = aws_instance.app.public_dns
            origin_id   = local.ec2_origin_id

            custom_origin_config {
              http_port              = 80
              https_port             = 443
              origin_protocol_policy = "http-only"
              origin_ssl_protocols   = ["TLSv1.2"]
            }
        }

        ordered_cache_behavior {
            path_pattern     = "/api/*"
            allowed_methods  = ["GET", "HEAD"]
            cached_methods   = ["GET", "HEAD"]
            target_origin_id = local.ec2_origin_id

            cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"

            viewer_protocol_policy   = "redirect-to-https"
            origin_request_policy_id = "b689b0a8-53d0-40ab-baf2-68738e2966ac"

        }

    }
