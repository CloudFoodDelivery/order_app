resource "aws_acm_certificate" "cert" {
  domain_name       = "www.devorderz.com"
  validation_method = "DNS"

  tags = {
    Name = "website-validation"
  }
}

resource "aws_route53_record" "cert" {
  for_each = { for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
    name   = dvo.resource_record_name
    type   = dvo.resource_record_type
    value  = dvo.resource_record_value
  }}

  zone_id = var.hosted_zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert : record.fqdn]
}
