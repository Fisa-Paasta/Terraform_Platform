variable "domain_name" {
  type        = string
  description = "도메인 이름 (예: www.example.com)"
}

variable "route53_zone_id" {
  type        = string
  description = "Route53 호스팅 영역의 ID"
}
