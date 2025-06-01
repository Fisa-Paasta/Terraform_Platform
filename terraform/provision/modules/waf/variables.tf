variable "name" {
  description = "WAF WebACL 이름 prefix"
  type        = string
}

variable "environment" {
  description = "배포 환경"
  type        = string
}

variable "cloudfront_arn" {
  description = "WAF를 연결할 CloudFront 배포 ARN"
  type        = string
}

variable "enable_geo_block" {
  description = "GeoMatch (국외 차단) 활성화 여부"
  type        = bool
  default     = true
}

variable "allowed_countries" {
  description = "허용 국가 목록 (GeoMatch 사용 시)"
  type        = list(string)
  default     = ["KR"] # 한국만 허용
}
