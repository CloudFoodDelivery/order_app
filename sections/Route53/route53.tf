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