resource "aws_route53_record" "cloudfront_alias" {
  zone_id = var.route53_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.cloudfront_domain
    zone_id                = "Z2FDTNDATAQYW2" # CloudFront 고정 zone ID
    evaluate_target_health = false
  }
}
