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
