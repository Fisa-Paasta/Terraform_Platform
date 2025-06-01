output "instance_profile_name" {
  value = aws_iam_instance_profile.ssm_profile.name
}

output "role_arn" {
  value = aws_iam_role.ssm_role.arn
}

output "slack_webhook_parameter_name" {
  value       = aws_ssm_parameter.slack_webhook.name
  description = "Slack Webhook SSM 파라미터 경로"
}
