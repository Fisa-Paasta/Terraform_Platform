<<<<<<< HEAD
resource "aws_iam_role" "resource_manager_exec" {
  name = "ResourceManagerLambdaRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "resource_manager_policy" {
  name = "ResourceManagerPolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstances",
          "ec2:TerminateInstances",
          "rds:DescribeDBInstances",
          "rds:DeleteDBInstance",
          "rds:ListTagsForResource",
          "eks:ListClusters",
          "eks:DescribeCluster",
          "eks:ListNodegroups",
          "eks:DeleteNodegroup",
          "eks:DeleteCluster",
          "s3:ListBucket",
          "s3:DeleteBucket",
          "s3:DeleteObject",
          "s3:GetBucketTagging",
          "dynamodb:ListTables",
          "dynamodb:DeleteTable",
          "dynamodb:ListTagsOfResource",
          "cloudfront:ListDistributions",
          "cloudfront:GetDistribution",
          "cloudfront:GetDistributionConfig",
          "cloudfront:UpdateDistribution",
          "cloudfront:DeleteDistribution",
          "cloudfront:ListTagsForResource",
          "wafv2:List*",
          "wafv2:DeleteWebACL",
          "wafv2:DeleteRuleGroup",
          "wafv2:ListTagsForResource",
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets",
          "route53:DeleteHostedZone",
          "route53:ListTagsForResource",
          "route53:ChangeResourceRecordSets",
          "logs:*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "resource_manager_attach" {
  role       = aws_iam_role.resource_manager_exec.name
  policy_arn = aws_iam_policy.resource_manager_policy.arn
}

module "resource_manager" {
  source   = "../modules/lambda"
  name     = "ResourceManager"
  filename = "${path.module}/packages/resource_manager.zip"
  role_arn = aws_iam_role.resource_manager_exec.arn
  runtime  = "python3.11"
  handler  = "index.lambda_handler"

  environment = {
    TAG_KEY       = "AutoStop"
    TAG_VALUE     = "true"
    SLACK_WEBHOOK = data.aws_ssm_parameter.slack_webhook.value
    FALLBACK_SNS  = "arn:aws:sns:${var.region}:${data.aws_caller_identity.current.account_id}:paasta-alert-topic"
  }
}

resource "aws_cloudwatch_event_rule" "resource_manager_schedule" {
  name                = "DailyResourceManager"
  schedule_expression = "cron(0 12 * * ? *)"
}

resource "aws_cloudwatch_event_target" "resource_manager_target" {
  rule      = aws_cloudwatch_event_rule.resource_manager_schedule.name
  target_id = "InvokeResourceManager"
  arn       = module.resource_manager.arn
}

resource "aws_lambda_permission" "resource_manager_invoke" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.resource_manager.name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.resource_manager_schedule.arn
}
=======
resource "aws_iam_role" "resource_manager_exec" {
  name = "ResourceManagerLambdaRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "resource_manager_policy" {
  name = "ResourceManagerPolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstances",
          "ec2:TerminateInstances",
          "rds:DescribeDBInstances",
          "rds:DeleteDBInstance",
          "rds:ListTagsForResource",
          "eks:ListClusters",
          "eks:DescribeCluster",
          "eks:ListNodegroups",
          "eks:DeleteNodegroup",
          "eks:DeleteCluster",
          "s3:ListBucket",
          "s3:DeleteBucket",
          "s3:DeleteObject",
          "s3:GetBucketTagging",
          "dynamodb:ListTables",
          "dynamodb:DeleteTable",
          "dynamodb:ListTagsOfResource",
          "cloudfront:ListDistributions",
          "cloudfront:GetDistribution",
          "cloudfront:GetDistributionConfig",
          "cloudfront:UpdateDistribution",
          "cloudfront:DeleteDistribution",
          "cloudfront:ListTagsForResource",
          "wafv2:List*",
          "wafv2:DeleteWebACL",
          "wafv2:DeleteRuleGroup",
          "wafv2:ListTagsForResource",
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets",
          "route53:DeleteHostedZone",
          "route53:ListTagsForResource",
          "route53:ChangeResourceRecordSets",
          "logs:*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "resource_manager_attach" {
  role       = aws_iam_role.resource_manager_exec.name
  policy_arn = aws_iam_policy.resource_manager_policy.arn
}

module "resource_manager" {
  source   = "../modules/lambda"
  name     = "ResourceManager"
  filename = "${path.module}/packages/resource_manager.zip"
  role_arn = aws_iam_role.resource_manager_exec.arn
  runtime  = "python3.11"
  handler  = "index.lambda_handler"

  environment = {
    TAG_KEY       = "AutoStop"
    TAG_VALUE     = "true"
    SLACK_WEBHOOK = data.aws_ssm_parameter.slack_webhook.value
    FALLBACK_SNS  = "arn:aws:sns:${var.region}:${data.aws_caller_identity.current.account_id}:paasta-alert-topic"
  }
}

resource "aws_cloudwatch_event_rule" "resource_manager_schedule" {
  name                = "DailyResourceManager"
  schedule_expression = "cron(0 12 * * ? *)"
}

resource "aws_cloudwatch_event_target" "resource_manager_target" {
  rule      = aws_cloudwatch_event_rule.resource_manager_schedule.name
  target_id = "InvokeResourceManager"
  arn       = module.resource_manager.arn
}

resource "aws_lambda_permission" "resource_manager_invoke" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.resource_manager.name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.resource_manager_schedule.arn
}
>>>>>>> 101118e (fix: refactor directort)
