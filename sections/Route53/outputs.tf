# route 53 Outputs
output "route53_zone_id" {
  description = "The ID of the Route 53 hosted zone."
  value       = aws_route53_zone.main.zone_id
}

output "route53_domain_name" {
  description = "The domain name of the Route 53 hosted zone."
  value       = aws_route53_zone.main.name
}

output "route53_record_fqdn" {
  description = "The fully qualified domain name (FQDN) of the Route 53 record."
  value       = aws_route53_record.devorderz.fqdn
}