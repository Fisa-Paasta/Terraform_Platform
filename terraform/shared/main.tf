resource "aws_iam_policy" "secrets_common" {
  name = "CommonSecretsAccessPolicy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = [
          "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:paasta/slack/*"
        ]
      }
    ]
  })
}

data "aws_caller_identity" "current" {}

variable "region" {
  type = string
}
