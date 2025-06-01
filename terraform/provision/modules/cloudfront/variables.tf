variable "name" {
  description = "Prefix name for CloudFront resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
}

variable "bucket_domain_name" {
  description = "S3 bucket domain name (e.g., bucket-name.s3.amazonaws.com)"
  type        = string
}

variable "s3_origin_id" {
  description = "CloudFront Origin ID for S3 bucket"
  type        = string
  default     = "S3Origin"
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for HTTPS"
  type        = string
}

variable "waf_web_acl_id" {
  description = "WAF WebACL ID to attach to CloudFront"
  type        = string
}
