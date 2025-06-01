resource "aws_iam_role" "ssm_role" {
  name = "${var.name}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "${var.name}-ssm-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "${var.name}-ssm-profile"
  role = aws_iam_role.ssm_role.name
}

resource "aws_ssm_parameter" "slack_webhook" {
  name        = "/paasta/slack/webhook"
  type        = "SecureString"
  value       = var.slack_webhook_url
  description = "Slack Webhook URL for alerts"

  tags = {
    Name        = "slack-webhook"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}
