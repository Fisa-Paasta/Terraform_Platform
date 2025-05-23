provider "aws" {
  region = var.region
}

data "aws_ssm_parameter" "slack_webhook" {
  name            = "/paasta/slack/webhook"
  with_decryption = true
}

resource "aws_iam_role" "cost_monitor_exec" {
  name = "CostMonitorLambdaRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "cost_monitor_policy" {
  name = "CostExplorerAccessPolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ce:GetCostAndUsage",
          "ssm:GetParameter"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cost_monitor_attach" {
  role       = aws_iam_role.cost_monitor_exec.name
  policy_arn = aws_iam_policy.cost_monitor_policy.arn
}

module "cost_monitor" {
  source   = "../modules/lambda"
  name     = "CostMonitor"
  filename = "${path.module}/packages/cost_monitor.zip"
  role_arn = aws_iam_role.cost_monitor_exec.arn
  runtime  = "python3.11"
  handler  = "index.lambda_handler"

  environment = {
    SLACK_WEBHOOK = data.aws_ssm_parameter.slack_webhook.value
  }
}

resource "aws_cloudwatch_event_rule" "cost_monitor_schedule" {
  name                = "DailyCostMonitor"
  schedule_expression = "cron(0 9 * * ? *)" # 매일 오전 6시 (KST 18:00)
}

resource "aws_cloudwatch_event_target" "cost_monitor_target" {
  rule      = aws_cloudwatch_event_rule.cost_monitor_schedule.name
  target_id = "InvokeCostMonitor"
  arn       = module.cost_monitor.arn
}

resource "aws_lambda_permission" "cost_monitor_invoke" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = module.cost_monitor.name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cost_monitor_schedule.arn
}
