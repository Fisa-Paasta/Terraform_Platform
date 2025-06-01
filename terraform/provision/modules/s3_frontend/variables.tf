variable "name" {
  description = "S3 bucket name prefix"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
}

variable "allowed_referers" {
  description = "List of allowed Referer values for accessing the S3 bucket"
  type        = list(string)
  default     = ["https://example.com"]
}
