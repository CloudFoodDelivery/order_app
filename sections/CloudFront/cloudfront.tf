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
    domain_name = aws_s3_bucket.example.bucket_regional_domain_name
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
