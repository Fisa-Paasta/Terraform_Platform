variable "name" {
  type = string
}

variable "environment" {
  type = string
}

variable "slack_webhook_url" {
  type        = string
  description = "Slack Webhook URL to store in SSM"
}
