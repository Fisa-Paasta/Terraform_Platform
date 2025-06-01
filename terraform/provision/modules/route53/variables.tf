variable "domain_name" {
  description = "도메인 이름 (예: www.example.com)"
  type        = string
}

variable "route53_zone_id" {
  description = "Route53 호스팅 영역의 ID"
  type        = string
}

variable "cloudfront_domain" {
  description = "CloudFront에서 제공하는 도메인 이름"
  type        = string
}
