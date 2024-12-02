resource "aws_route53_record" "www" {
  zone_id = var.hosted_zone_id
  name    = "www.devorderz.com"
  type    = "CNAME"

  records = [aws_cloudfront_distribution.main.domain_name]
  ttl     = 300
}
