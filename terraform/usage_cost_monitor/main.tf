data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "slack_webhook" {
  name = "/paasta/slack/webhook"
}

resource "aws_iam_role" "usage_cost_exec" {
  name = "UsageCostMonitorLambdaRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "usage_cost_basic" {
  name = "UsageCostBasicPolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "cloudwatch:GetMetricData",
          "cloudwatch:ListMetrics",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:DescribeAlarms",
          "lambda:ListFunctions",
          "lambda:GetFunctionConfiguration",
          "ec2:DescribeInstances",
          "ec2:DescribeVolumes",
          "eks:ListClusters",
          "eks:DescribeCluster",
          "rds:DescribeDBInstances",
          "s3:ListAllMyBuckets",
          "s3:GetBucketTagging",
          "tag:GetResources",
          "logs:*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "usage_cost_ssm" {
  name = "UsageCostSSMPolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ],
        Resource = "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/paasta/slack/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "basic_attach" {
  role       = aws_iam_role.usage_cost_exec.name
  policy_arn = aws_iam_policy.usage_cost_basic.arn
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.usage_cost_exec.name
  policy_arn = aws_iam_policy.usage_cost_ssm.arn
}

module "usage_cost_monitor" {
  source   = "../modules/lambda"
  name     = "UsageCostMonitor"
  filename = "${path.module}/packages/usage_cost_monitor.zip"
  role_arn = aws_iam_role.usage_cost_exec.arn
  runtime  = "python3.11"
  handler  = "handler.lambda_handler"

  environment = {
    SLACK_WEBHOOK = data.aws_ssm_parameter.slack_webhook.value
  }
}

resource "aws_cloudwatch_event_rule" "daily_trigger" {
  name                = "DailyUsageCostTrigger"
  schedule_expression = "cron(0 0 * * ? *)" # 매일 자정 UTC
}

resource "aws_cloudwatch_event_target" "trigger_lambda" {
  rule      = aws_cloudwatch_event_rule.daily_trigger.name
  target_id = "UsageCostMonitorTarget"
  arn       = module.usage_cost_monitor.arn
}

resource "aws_lambda_permission" "allow_events" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.usage_cost_monitor.name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_trigger.arn
}
