<<<<<<< HEAD

=======

resource "aws_wafv2_web_acl" "this" {
  name        = "${var.name}-${var.environment}-acl"
  scope       = "CLOUDFRONT"
  description = "WAF for CloudFront"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.name}-web-acl"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "AWSManagedRulesCommon"
    priority = 0
    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSCommonRules"
      sampled_requests_enabled   = true
    }
  }

  dynamic "rule" {
    for_each = var.enable_geo_block ? [1] : []
    content {
      name     = "GeoBlock"
      priority = 1

      action {
        block {}
      }

      statement {
        not_statement {
          statement {
            geo_match_statement {
              country_codes = var.allowed_countries
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "GeoBlock"
        sampled_requests_enabled   = true
      }
    }
  }

  tags = {
    Name        = "${var.name}-web-acl"
    Environment = var.environment
  }
}

resource "aws_wafv2_web_acl_association" "cf_assoc" {
  resource_arn = var.cloudfront_arn
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}
>>>>>>> 101118e (fix: refactor directort)
