# DNS record for CF CDN
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.devorderz.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = false
  }
}
#DNS record for devorderz.com (root domain) pointing to CloudFront
resource "aws_route53_record" "root" {
  zone_id = aws_route53_zone.main.zone_id
  name = "devorderz.com" #Root domain
  type = "A"

  alias {
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = false
  }
}
  