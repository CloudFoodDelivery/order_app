resource "aws_acm_certificate" "example" {
  domain_name       = "www.devorderz.com"
  validation_method = "DNS"

  tags = {
    Name = "website-validation"
  }
}

resource "aws_route53_record" "example" {
  zone_id = "Z0435126RW01UPASMOSL" # Replace with your Route 53 Hosted Zone ID
  name    = aws_acm_certificate.example.domain_validation_options[0].resource_record_name
  type    = aws_acm_certificate.example.domain_validation_options[0].resource_record_type
  records = [aws_acm_certificate.example.domain_validation_options[0].resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "example" {
  certificate_arn         = aws_acm_certificate.example.arn
  validation_record_fqdns = [aws_route53_record.example.fqdn]
}