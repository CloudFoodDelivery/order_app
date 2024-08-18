terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# create a new S3 bucket
resource "aws_s3_bucket" "s3_bucket" {
  bucket = "www.devorderz.com"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

# Set public access block configuration
resource "aws_s3_bucket_public_access_block" "s3_bucket" {
  bucket = aws_s3_bucket.example.id

  block_public_acls   = false
  block_public_policy = false
}

# Set bucket policy to make it publicly accessible
resource "aws_s3_bucket_policy" "s3_bucet" {
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
            "Resource": "arn:aws:s3:::www.devorderz.com/*"
        }
    ]
}
POLICY
}

#Request Certificate from ACM
resource "aws_acm_certificate" "website_cert" {
  domain_name = "devorderz.com"
  validation_method = "DNS"

  subject_alternative_names = [
    "www.devorderz.com",
  ]

  tags = {
    Name = " website_cert"
  }
}

# DNS validation using Route 53
resources "aws_route53_record" "website_cert_validation" {
  for_each = {
    for dvo in aws_acm_certification.website_cert.domain_validation_options : dvo.domain_name => {
      name = dvo.resource_record_name
      type = dvo.resource_record_type
      record = dvp.resource_record_value
    }
  }

  zone_id = aws_route53_zone.main.zone_id
  name = each.value.name
  type = each.value.type
  ttl = 60
  records = [each.value.record]
}

# Wait for the vaidation to complete
resource "aws_acm_certificate_validation" "website_cert_validation" {
  certificate_arn = aws_acm_certificate.website_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.website_cert_validation : record.fqdn]
}

# Defined CF Distribution 
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

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certification_arn = aws_acm_certificate_validation.website_cert_validation.certificate_arn
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
    cloudfront_default_certificate = false
  }
}

# Hosted zone for your Route 53 domain
resource "aws_route53_zone" "main" {
  name = "devorderz.com"
}

# DNS record for CF CDN
resource "aws_route53_record" "devorderz" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "devorderz.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = false
  }
}

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

  mfa_configuration         = "OPTIONAL"
  auto_verified_attributes  = ["email"]

  admin_create_user_config {
    allow_admin_create_user_only = true
  }
}

# Cognito User Pool Client
resource "aws_cognito_user_pool_client" "project_user_pool_client" {
  name               = "project-user-pool-client"
  user_pool_id       = aws_cognito_user_pool.project_user_pool.id

  generate_secret    = false

  callback_urls      = ["https://devorderz.com/callback"]

  allowed_oauth_flows               = ["code"]
  allowed_oauth_scopes              = ["email","openid","profile"]
  allowed_oauth_flows_user_pool_client = true
}

#Create a WAFv2 Web aws_cloudfront_distribution
resource "aws_wafv2_web_acl "main "{
  name = "main-waf-acl"
  description = "Main WAF ACL"
  scope = "CLOUDFRONT" 

  default_action {
    allow {}
  }

  visibility_config{
    cloudwatch_metrics_enable_true
    metric_name = "main-waf-acl"
    sampled_requests_enabled = true
  }

  rule{
    name ="rate-limit"
    priority = 1

    action {
      block {} #Blcok the request if it exceeds the rate limit
    }

    statement {
      rate_based_statement {
        limit = 1000 #Adjust the rate limit as needed
        aggregate_key_type = "IP"
      }
    }

    visibility_config{
      cloudwatch_metrics_enabled = true
      metric_name = "rate-limit"
      sampled_requests_enambled = true
    }
  }
}
