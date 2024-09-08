terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

<<<<<<< HEAD
# Hosted zone for your Route 53 domain
resource "aws_route53_zone" "main" {
  name = "devorderz.com"
}

=======
provider "aws" {
  region = "us-east-2"
}

# ------------------------------
# S3 Bucket and Configuration
# ------------------------------

>>>>>>> main
# Create a new S3 bucket
resource "aws_s3_bucket" "s3_bucket" {
  bucket = "www.devorderz.com"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

# Set public access block configuration
<<<<<<< HEAD
resource "aws_s3_bucket_public_access_block" "s3_bucket_access_block" {
=======
resource "aws_s3_bucket_public_access_block" "s3_bucket_public_access_block" {
>>>>>>> main
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
            "Resource": "arn:aws:s3:::www.devorderz.com/*"
        }
    ]
}
POLICY
}

<<<<<<< HEAD
=======
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

>>>>>>> main
# Request Certificate from ACM
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

# DNS validation using Route 53
resource "aws_route53_record" "website_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.website_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

# Wait for the validation to complete
resource "aws_acm_certificate_validation" "website_cert_validation" {
  certificate_arn         = aws_acm_certificate.website_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.website_cert_validation : record.fqdn]
}

<<<<<<< HEAD
=======
# ------------------------------
# CloudFront Distribution
# ------------------------------

>>>>>>> main
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
    acm_certificate_arn            = aws_acm_certificate_validation.website_cert_validation.certificate_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2018"
    cloudfront_default_certificate = false
  }
<<<<<<< HEAD
}

# DNS record for CloudFront CDN
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

  mfa_configuration        = "OPTIONAL"
  auto_verified_attributes = ["email"]

  admin_create_user_config {
    allow_admin_create_user_only = true
  }
}

# Cognito User Pool Client
resource "aws_cognito_user_pool_client" "project_user_pool_client" {
  name                                 = "project-user-pool-client"
  user_pool_id                         = aws_cognito_user_pool.project_user_pool.id
  generate_secret                      = false
  callback_urls                        = ["https://devorderz.com/callback"]
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["email", "openid", "profile"]
  allowed_oauth_flows_user_pool_client = true
}

# Create a WAFv2 Web ACL for CloudFront Distribution
=======

  web_acl_id = aws_wafv2_web_acl.main.arn
}

# ------------------------------
# WAFv2 Web ACL
# ------------------------------

# Create a WAFv2 Web ACL
>>>>>>> main
resource "aws_wafv2_web_acl" "main" {
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

<<<<<<< HEAD
# AWS Step Functions for Purchase Process
resource "aws_fd_purchase_process_machine" "step_function_machine" {
  name     = "StepFunctionMachine"
  role_arn = "arn:aws:iam::730335569978:role/service-role/StepFunctions-FD-PURCHASE-PROCESS-MACHINE-role-nkbxyfivf"

  definition = jsonencode({
    Comment = "A description of my state machine",
    StartAt = "Choice",
    States = {
      Choice = {
        Type = "Choice",
        Choices = [
          {
            Variable     = "$.type",
            StringEquals = "PURCHASE",
            Next         = "Purchase Handler"
          },
          {
            Variable     = "$.type",
            StringEquals = "REFUND",
            Next         = "Refund Handler"
          }
        ],
        Default = "Result Handler"
      },
      "Purchase Handler" = {
        Type       = "Task",
        Resource   = "arn:aws:states:::lambda:invoke",
        OutputPath = "$.Payload",
        Parameters = {
          "Payload.$"  = "$",
          FunctionName = "arn:aws:lambda:us-east-2:730335569978:function:PurchaseHandler:$LATEST"
        },
        Retry = [
          {
            ErrorEquals = [
              "Lambda.ServiceException",
              "Lambda.AWSLambdaException",
              "Lambda.SdkClientException",
              "Lambda.TooManyRequestsException"
            ],
            IntervalSeconds = 1,
            MaxAttempts     = 3,
            BackoffRate     = 2
          }
        ],
        Next = "Result Handler"
      },
      "Result Handler" = {
        Type       = "Task",
        Resource   = "arn:aws:states:::lambda:invoke",
        OutputPath = "$.Payload",
        Parameters = {
          "Payload.$"  = "$",
          FunctionName = "arn:aws:lambda:us-east-2:730335569978:function:ResultHandler:$LATEST"
        },
        Retry = [
          {
            ErrorEquals = [
              "Lambda.ServiceException",
              "Lambda.AWSLambdaException",
              "Lambda.SdkClientException",
              "Lambda.TooManyRequestsException"
            ],
            IntervalSeconds = 1,
            MaxAttempts     = 3,
            BackoffRate     = 2
          }
        ],
        End = true
      },
      "Refund Handler" = {
        Type       = "Task",
        Resource   = "arn:aws:states:::lambda:invoke",
        OutputPath = "$.Payload",
        Parameters = {
          "Payload.$"  = "$",
          FunctionName = "arn:aws:lambda:us-east-2:730335569978:function:RefundHandler:$LATEST"
        },
        Retry = [
          {
            ErrorEquals = [
              "Lambda.ServiceException",
              "Lambda.AWSLambdaException",
              "Lambda.SdkClientException",
              "Lambda.TooManyRequestsException"
            ],
            IntervalSeconds = 1,
            MaxAttempts     = 3,
            BackoffRate     = 2
          }
        ],
        Next = "Result Handler"
      }
    }
  })

  tags = {
    Name        = "Step Function Machine"
    Environment = "Dev"
  }
}

output "website_url" {
  value = "https://${aws_cloudfront_distribution.main.domain_name}"
=======
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

# Define your Lambda functions (ensure these are properly configured)
resource "aws_lambda_function" "customer_function" {
  function_name = "customer-function"
  role          = "add/attach customer order"
  # Add the rest of the configuration here
}

resource "aws_lambda_function" "order_function" {
  function_name = "order-function"
  role          = "process orders"
  # Add the rest of the configuration here
}


# ------------------------------
# API Gateway Configuration
# ------------------------------

# New API Gateway
resource "aws_api_gateway_rest_api" "example" {
  name        = "example-api"
  description = "Example API Gateway"
}

# ---- Customer Resource ----

# API Gateway Resource for Customer
resource "aws_api_gateway_resource" "customer_resource" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  parent_id   = aws_api_gateway_rest_api.example.root_resource_id
  path_part   = "customer"
}

# API Method for Customer
resource "aws_api_gateway_method" "customer_method" {
  rest_api_id   = aws_api_gateway_rest_api.example.id
  resource_id   = aws_api_gateway_resource.customer_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# Integration with Lambda for Customer
resource "aws_api_gateway_integration" "customer_integration" {
  rest_api_id             = aws_api_gateway_rest_api.example.id
  resource_id             = aws_api_gateway_resource.customer_resource.id
  http_method             = aws_api_gateway_method.customer_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.customer_function.invoke_arn
}

# Lambda Permission for API Gateway to invoke Customer Lambda
resource "aws_lambda_permission" "customer_api_permission" {
  statement_id  = "AllowAPIGatewayInvokeCustomer"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.customer_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.example.execution_arn}/*/*"
}

# ---- Food Items Resource ----

# API Gateway Resource for Food Items
resource "aws_api_gateway_resource" "food_items_resource" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  parent_id   = aws_api_gateway_rest_api.example.root_resource_id
  path_part   = "food-items"
}

# API Method for Food Items
resource "aws_api_gateway_method" "food_items_method" {
  rest_api_id   = aws_api_gateway_rest_api.example.id
  resource_id   = aws_api_gateway_resource.food_items_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# Integration with Lambda for Food Items
resource "aws_api_gateway_integration" "food_items_integration" {
  rest_api_id             = aws_api_gateway_rest_api.example.id
  resource_id             = aws_api_gateway_resource.food_items_resource.id
  http_method             = aws_api_gateway_method.food_items_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.order_function.invoke_arn
}

# Lambda Permission for API Gateway to invoke Order Lambda
resource "aws_lambda_permission" "food_items_api_permission" {
  statement_id  = "AllowAPIGatewayInvokeFoodItems"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.order_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.example.execution_arn}/*/*"
}

# ---- Order Items Resource ----

# API Gateway Resource for Order Items
resource "aws_api_gateway_resource" "order_items_resource" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  parent_id   = aws_api_gateway_rest_api.example.root_resource_id
  path_part   = "order-items"
}

# API Method for Order Items
resource "aws_api_gateway_method" "order_items_method" {
  rest_api_id   = aws_api_gateway_rest_api.example.id
  resource_id   = aws_api_gateway_resource.order_items_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# Integration with Lambda for Order Items
resource "aws_api_gateway_integration" "order_items_integration" {
  rest_api_id             = aws_api_gateway_rest_api.example.id
  resource_id             = aws_api_gateway_resource.order_items_resource.id
  http_method             = aws_api_gateway_method.order_items_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.order_function.invoke_arn
}

# Lambda Permission for API Gateway to invoke Order Lambda
resource "aws_lambda_permission" "order_items_api_permission" {
  statement_id  = "AllowAPIGatewayInvokeOrderItems"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.order_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.example.execution_arn}/*/*"
}

# ---- Orders Resource ----

# API Gateway Resource for Orders
resource "aws_api_gateway_resource" "orders_resource" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  parent_id   = aws_api_gateway_rest_api.example.root_resource_id
  path_part   = "orders"
}

# API Method for Orders
resource "aws_api_gateway_method" "orders_method" {
  rest_api_id   = aws_api_gateway_rest_api.example.id
  resource_id   = aws_api_gateway_resource.orders_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# Integration with Lambda for Orders
resource "aws_api_gateway_integration" "orders_integration" {
  rest_api_id             = aws_api_gateway_rest_api.example.id
  resource_id             = aws_api_gateway_resource.orders_resource.id
  http_method             = aws_api_gateway_method.orders_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.order_function.invoke_arn
}

# Lambda Permission for API Gateway to invoke Order Lambda
resource "aws_lambda_permission" "orders_api_permission" {
  statement_id  = "AllowAPIGatewayInvokeOrders"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.order_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.example.execution_arn}/*/*"
}

# ------------------------------
# API Gateway Deployment
# ------------------------------

# Deploy the API Gateway
resource "aws_api_gateway_deployment" "example_deployment" {
  depends_on = [
    aws_api_gateway_integration.customer_integration,
    aws_api_gateway_integration.food_items_integration,
    aws_api_gateway_integration.order_items_integration,
    aws_api_gateway_integration.orders_integration
  ]
  rest_api_id = aws_api_gateway_rest_api.example.id
  stage_name  = "prod"
>>>>>>> main
}
