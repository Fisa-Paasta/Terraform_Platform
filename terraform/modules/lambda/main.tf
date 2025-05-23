resource "aws_lambda_function" "this" {
  function_name = var.name
  handler       = var.handler
  runtime       = var.runtime
  filename      = var.filename
  role          = var.role_arn

  environment {
    variables = var.environment
  }

  source_code_hash = filebase64sha256(var.filename)
}

resource "aws_cloudwatch_log_group" "lambda_log" {
  name              = "/aws/lambda/${var.name}"
  retention_in_days = var.log_retention
}
