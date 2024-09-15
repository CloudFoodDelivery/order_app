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
