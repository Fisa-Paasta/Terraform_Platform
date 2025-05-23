provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "slack_webhook" {
  name            = "/paasta/slack/webhook"
  with_decryption = true
}
