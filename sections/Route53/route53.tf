# Hosted zone for your Route 53 domain

resource "aws_route53_zone" "main" {
  name = "replacethisdomain.com" # Replace with your registered domain
}

#DNS record for CF CDN
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = false
  }
}