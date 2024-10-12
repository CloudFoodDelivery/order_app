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
    allowed_methods            = ["GET", "DELETE", "OPTIONS", "PATCH", "HEAD"]
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

  web_acl_id = aws_wafv2_web_acl.main.arn
}
