terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Provider for us-east-2 (default region for most resources)
provider "aws" {
  region = "us-east-2"
}

# Provider for us-east-1 (specific for CloudFront WAF)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

# ------------------------------
# S3 Bucket and Configuration
# ------------------------------

# Create a new S3 bucket
resource "aws_s3_bucket" "s3_bucket" {
  bucket = "devorderz-bucket"

  tags = {
    Name        = "website-bucket"
    Environment = "Dev"
  }
}

# Set public access block configuration
resource "aws_s3_bucket_public_access_block" "s3_bucket_public_access_block" {
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls   = false
  block_public_policy = false
}

# Set bucket policy to make it publicly accessible
resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = aws_s3_bucket.s3_bucket.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Statement1",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::devorderz-bucket/*"
        }
    ]
}
POLICY
}

# ------------------------------
# Route 53 Hosted Zone and Records
# ------------------------------

# Hosted zone for your Route 53 domain
resource "aws_route53_zone" "main" {
  name = "devorderz.com"
}

# DNS record for CloudFront CDN (devorderz.com)
resource "aws_route53_record" "devorderz" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "devorderz.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = "Z2FDTNDATAQYW2" # CloudFront Hosted Zone ID
    evaluate_target_health = false
  }
}

# DNS record for CloudFront CDN (www.devorderz.com)
resource "aws_route53_record" "www_devorderz" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.devorderz.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = "Z2FDTNDATAQYW2" # CloudFront Hosted Zone ID
    evaluate_target_health = false
  }
}

# ------------------------------
# ACM Certificate and Validation
# ------------------------------

# ACM certificate resource for us-east-1 CF connection
resource "aws_acm_certificate" "website_cert_us_east_1" {
  provider          = aws.us_east_1 # Specify that this certificate is in us-east-1
  domain_name       = "devorderz.com"
  validation_method = "DNS"

  subject_alternative_names = [
    "www.devorderz.com",
  ]

  tags = {
    Name = "website_cert_us_east_1"
  }
}

# Request Certificate from ACM (Backup in us-east-2, but not used)
resource "aws_acm_certificate" "website_cert" {
  domain_name       = "devorderz.com"
  validation_method = "DNS"

  subject_alternative_names = [
    "www.devorderz.com",
  ]

  tags = {
    Name = "website_cert"
  }
}

# ROUTE53/ACM certificate validation for the us-east-1 certificate
resource "aws_route53_record" "website_cert_validation_us_east_1" {
  for_each = {
    for dvo in aws_acm_certificate.website_cert_us_east_1.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 300
  records = [each.value.record]
}

# ------------------------------
# CloudFront Distribution
# ------------------------------

# Define CloudFront Distribution
resource "aws_cloudfront_distribution" "main" {
  origin {
    domain_name = aws_s3_bucket.s3_bucket.bucket_regional_domain_name
    origin_id   = "myS3Origin"
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "S3 CloudFront Distribution"
  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id       = "myS3Origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate.website_cert_us_east_1.arn # Reference the certificate in us-east-1
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2018"
    cloudfront_default_certificate = false
  }

  web_acl_id = aws_wafv2_web_acl.main.arn
}

# ------------------------------
# WAFv2 Web ACL (deployed in us-east-1)
# ------------------------------

# Create a WAFv2 Web ACL
resource "aws_wafv2_web_acl" "main" {
  provider    = aws.us_east_1 # Use the us-east-1 provider for CloudFront WAF
  name        = "main-waf-acl"
  description = "Main WAF ACL"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "main-waf-acl"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "rate-limit"
    priority = 1

    action {
      block {} # Block the request if it exceeds the rate limit
    }

    statement {
      rate_based_statement {
        limit              = 1000 # Adjust the rate limit as needed
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "rate-limit"
      sampled_requests_enabled   = true
    }
  }
}

# ------------------------------
# Cognito User Pool and Client
# ------------------------------

# Cognito User Pool
resource "aws_cognito_user_pool" "project_user_pool" {
  name = "project-user-pool"

  password_policy {
    minimum_length    = 8
    require_uppercase = true
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
  }

  mfa_configuration        = "OPTIONAL"
  auto_verified_attributes = ["email"]

  admin_create_user_config {
    allow_admin_create_user_only = true
  }
}

# Cognito User Pool Client
resource "aws_cognito_user_pool_client" "project_user_pool_client" {
  name         = "project-user-pool-client"
  user_pool_id = aws_cognito_user_pool.project_user_pool.id

  generate_secret = false

  callback_urls = ["https://devorderz.com/callback"]

  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["email", "openid", "profile"]
  allowed_oauth_flows_user_pool_client = true
}

# ------------------------------
# Lambda Functions
# ------------------------------

# Data source for customer Lambda function code archive
data "archive_file" "lambda_zip_customer" {
  type        = "zip"
  source_dir  = "${path.module}/sections/Compute/lambda/customers/lamda_function_customer"
  output_path = "${path.module}/lambda_function_customer.zip"
}

# Data source for order Lambda function code archive
data "archive_file" "lambda_zip_order" {
  type        = "zip"
  source_dir  = "${path.module}/sections/Compute/lambda/food_items_lambda/items_storage"
  output_path = "${path.module}/lambda_function_order.zip"
}

# Data source for food items Lambda function code archive
data "archive_file" "lambda_zip_food_items" {
  type        = "zip"
  source_dir  = "${path.module}/sections/Compute/lambda/food_items_lambda/items_storage"
  output_path = "${path.module}/lambda/fooditems.zip"
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com" # Correctly specify Lambda service as the Principal
        }
      }
    ]
  })
}
