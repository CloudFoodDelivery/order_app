# Hosted zone for your Route 53 domain

resource "aws_route53_zone" "devorderz_com" {
  name = "devorderz.com"
}

resource "aws_route53_query_logging_config" "dev_logs" {
  name                      = "dev_logs-logging-config"
  record_type               = "QUERY_LOGGING"
  cloudwatch_logs_group_arn = aws_cloudwatch_log_group.dev_logs.arn
}

resource "aws_route53_zone" "devorderz" {
  name = "devorderz.com."

}

resource "aws_cloudwatch_log_group" "devorderz_group" {
  name = "devoerderz_group-logs"
}

# DNS record for CF cdn
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
