output "route53_record_fqdn" {
  description = "Route53에 등록된 FQDN"
  value       = aws_route53_record.cloudfront_alias.fqdn
}
