<<<<<<< HEAD
resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket_versioning" "resource_log" {
  bucket = aws_s3_bucket.resource_log.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_role" "resource_log_exec" {
  name = "ResourceLogLambdaRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "resource_log_basic" {
  name = "ResourceLogPolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["logs:*", "s3:PutObject"],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "resource_log_ssm" {
  name = "ResourceLogSSMPolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["ssm:GetParameter", "ssm:GetParameters"],
        Resource = "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/paasta/slack/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "basic_attach" {
  role       = aws_iam_role.resource_log_exec.name
  policy_arn = aws_iam_policy.resource_log_basic.arn
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.resource_log_exec.name
  policy_arn = aws_iam_policy.resource_log_ssm.arn
}

module "resource_log_collector" {
  source   = "../modules/lambda"
  name     = "ResourceLogCollector"
  filename = "${path.module}/packages/resource_log_collector.zip"
  role_arn = aws_iam_role.resource_log_exec.arn
  runtime  = "python3.11"
  handler  = "index.lambda_handler"

  environment = {
    LOG_BUCKET    = aws_s3_bucket.resource_log.bucket
    SLACK_WEBHOOK = data.aws_ssm_parameter.slack_webhook.value
  }
}

resource "aws_lambda_permission" "resource_log_triggers" {
  for_each = toset(var.resource_log_groups)

  statement_id  = "AllowFromCW-${replace(each.value, "/", "-")}"
  action        = "lambda:InvokeFunction"
  function_name = module.resource_log_collector.name
  principal     = "logs.amazonaws.com"
  source_arn    = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:${each.value}:*"
}

resource "aws_cloudwatch_log_subscription_filter" "resource_log_to_lambda" {
  for_each = toset(var.resource_log_groups)

  name            = "ToResourceLog-${replace(each.value, "/", "-")}"
  log_group_name  = each.value
  destination_arn = module.resource_log_collector.arn
  filter_pattern  = ""

  depends_on = [aws_lambda_permission.resource_log_triggers]
}
=======
resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "resource_log" {
  bucket        = "resource-log-${random_id.suffix.hex}"
  force_destroy = true

  tags = {
    Name = "ResourceLogCollectorBucket"
  }
}

resource "aws_s3_bucket_versioning" "resource_log" {
  bucket = aws_s3_bucket.resource_log.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_role" "resource_log_exec" {
  name = "ResourceLogLambdaRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "resource_log_basic" {
  name = "ResourceLogPolicy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["logs:*", "s3:PutObject"],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "resource_log_ssm" {
  name = "ResourceLogSSMPolicy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["ssm:GetParameter", "ssm:GetParameters"],
        Resource = "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/paasta/slack/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "basic_attach" {
  role       = aws_iam_role.resource_log_exec.name
  policy_arn = aws_iam_policy.resource_log_basic.arn
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.resource_log_exec.name
  policy_arn = aws_iam_policy.resource_log_ssm.arn
}

module "resource_log_collector" {
  source   = "../modules/lambda"
  name     = "ResourceLogCollector"
  filename = "${path.module}/packages/resource_log_collector.zip"
  role_arn = aws_iam_role.resource_log_exec.arn
  runtime  = "python3.11"
  handler  = "index.lambda_handler"

  environment = {
    LOG_BUCKET    = aws_s3_bucket.resource_log.bucket
    SLACK_WEBHOOK = data.aws_ssm_parameter.slack_webhook.value
  }
}

resource "aws_lambda_permission" "resource_log_triggers" {
  for_each = toset(var.resource_log_groups)

  statement_id  = "AllowFromCW-${replace(each.value, "/", "-")}"
  action        = "lambda:InvokeFunction"
  function_name = module.resource_log_collector.name
  principal     = "logs.amazonaws.com"
  source_arn    = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:${each.value}:*"
}

resource "aws_cloudwatch_log_subscription_filter" "resource_log_to_lambda" {
  for_each = toset(var.resource_log_groups)

  name            = "ToResourceLog-${replace(each.value, "/", "-")}"
  log_group_name  = each.value
  destination_arn = module.resource_log_collector.arn
  filter_pattern  = ""

  depends_on = [aws_lambda_permission.resource_log_triggers]
}
>>>>>>> 101118e (fix: refactor directort)
