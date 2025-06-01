output "waf_web_acl_arn" {
  description = "WAF WebACL ARN"
  value       = aws_wafv2_web_acl.this.arn
}

output "waf_web_acl_id" {
  value = aws_wafv2_web_acl.this.id
}
