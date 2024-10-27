terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Provider Configuration
provider "aws" {
  region = "us-east-2" # Default region for most resources
}

provider "aws" {
  alias  = "us_east_1" # Provider for us-east-1 (CloudFront and WAF)
  region = "us-east-1"
}

# ------------------------------
# S3 Bucket and Configuration
# ------------------------------

resource "aws_s3_bucket" "s3_bucket" {
  bucket = "devorderz.com"

  lifecycle {
    prevent_destroy = true
    ignore_changes  = all
  }
}

resource "aws_s3_bucket_public_access_block" "s3_bucket_public_access_block" {
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls   = false
  block_public_policy = false
}

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
      "Resource": "arn:aws:s3:::devorderz.com/*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudfront.amazonaws.com"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::devorderz.com/*",
      "Condition": {
        "StringEquals": {
          "AWS:SourceArn": "arn:aws:cloudfront::EYFRSGMITV7S9"
        }
      }
    }
  ]
}
POLICY
}
#----------------------------
#S3 Bucket SNS notifications
#----------------------------

resource "aws_sns_topic" "bucket_notifications" {
  name = "bucket-notifications"
}


# ------------------------------
# Route 53 Hosted Zone and Records
# ------------------------------

resource "aws_route53_zone" "devorderz_com" {
  name = "devorderz.com"
}

resource "aws_cloudwatch_log_group" "devorderz_group" {
  name = "devoerderz_group-logs"
}

# ------------------------------
# ACM Certificate and Validation
# ------------------------------

resource "aws_acm_certificate" "website_cert_us_east_1" {
  provider          = aws.us_east_1
  domain_name       = "devorderz.com"
  validation_method = "DNS"

  subject_alternative_names = ["www.devorderz.com"]
}

resource "aws_acm_certificate" "website_cert" {
  domain_name       = "devorderz.com"
  validation_method = "DNS"

  subject_alternative_names = ["www.devorderz.com"]
}

#----------------------------------
#Declared CF Resources
#----------------------------------

resource "aws_cloudfront_origin_access_control" "default" {
  name                              = "devorderz-oac"
  description                       = "Origin Access Control for S3 bucket access"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
resource "aws_cloudfront_response_headers_policy" "pass" {
  name = "devorderz-response-headers-policy"

  # Example: set security headers
  security_headers_config {
    content_security_policy {
      override                = true
      content_security_policy = "default-src 'self';"
    }
    content_type_options {
      override = true
    }
    frame_options {
      frame_option = "DENY"
      override     = true
    }
    referrer_policy {
      referrer_policy = "no-referrer"
      override        = true
    }
    strict_transport_security {
      access_control_max_age_sec = 63072000
      include_subdomains         = true
      override                   = true
    }
    xss_protection {
      override   = true
      protection = true
      mode_block = true
    }
  }
}





# ------------------------------
# CloudFront Distribution
# ------------------------------

resource "aws_cloudfront_distribution" "devorderz" {
  origin {
    domain_name              = "devorderz.com.s3.amazonaws.com"
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
    origin_id                = "devorderz.com"
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "S3 CloudFront Distribution"
  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id           = "devorderz.com"
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods             = ["GET", "HEAD"]
    response_headers_policy_id = aws_cloudfront_response_headers_policy.pass.id

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
  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "devorderz.com"

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }
  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = "arn:aws:acm:us-east-1:730335569978:certificate/40cb4570-84e3-4a57-83f7-302519827a39"
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2018"
    cloudfront_default_certificate = false
  }

  web_acl_id = aws_wafv2_web_acl.main.arn
}

# ------------------------------
# WAFv2 Web ACL (deployed in us-east-1)
# ------------------------------

resource "aws_wafv2_web_acl" "main" {
  provider    = aws.us_east_1
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
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 1000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "rate-limit"
      sampled_requests_enabled   = true
    }
  }

  # Rule 1: Rate Limit Rule
  rule {
    name     = "rate-limit"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 1000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "rate-limit"
      sampled_requests_enabled   = true
    }
  }

  # Rule 2: AWS Managed Rules for Anonymous IP List
  rule {
    name     = "rule-1"
    priority = 2

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAnonymousIpList"
        vendor_name = "AWS"


        scope_down_statement {
          geo_match_statement {
            country_codes = ["US", "NL"]
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "friendly-rule-metric-1"
      sampled_requests_enabled   = false
    }
  }

  # Rule 3: AWS Managed Rules for Known Bad Inputs
  rule {
    name     = "rule-2"
    priority = 3

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"

        scope_down_statement {
          geo_match_statement {
            country_codes = ["US", "NL"]
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "friendly-rule-metric-2"
      sampled_requests_enabled   = false
    }
  }

  tags = {
    Tag1 = "Value1"
    Tag2 = "Value2"
  }
}


# ------------------------------
# Cognito User Pool and Client
# ------------------------------

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

data "archive_file" "lambda_zip_customer" {
  type        = "zip"
  source_dir  = "${path.module}/sections/Compute/lambda/customers/lamda_function_customer"
  output_path = "${path.module}/lambda_function_customer.zip"
}

data "archive_file" "lambda_zip_order" {
  type        = "zip"
  source_dir  = "${path.module}/sections/Compute/lambda/food_items_lambda/items_storage"
  output_path = "${path.module}/lambda_function_order.zip"
}

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
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# ------------------------------
# RDS Instances
# ------------------------------

#  VPC Configuration
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Define Subnets in us-east-2a and us-east-2b
resource "aws_subnet" "subnet_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-2a"
}

resource "aws_subnet" "subnet_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-2b"
}

# Define RDS Subnet Group with these subnets
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]

  tags = {
    Name = "RDS subnet group"
  }
}

#RDS Security Groups
# Security Group for RDS Instances
resource "aws_security_group" "sg_rds" {
  vpc_id      = aws_vpc.main.id
  description = "Security group for RDS instances"

  # Allow inbound access on MySQL port 3306
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Modify this as needed for more restricted access
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-security-group"
  }
}



resource "aws_db_instance" "rds_instance1" {
  allocated_storage      = 20
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  username               = var.db_username1
  password               = var.db_password1
  vpc_security_group_ids = [aws_security_group.sg_rds.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  skip_final_snapshot    = false
}

resource "aws_db_instance" "rds_instance2" {
  allocated_storage      = 20
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  username               = var.db_username2
  password               = var.db_password2
  vpc_security_group_ids = [aws_security_group.sg_rds.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  skip_final_snapshot    = false
}
