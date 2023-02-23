provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
  default_tags {
    tags = {
      aws-exam-resource = true
    }
  }
}

resource "aws_wafv2_web_acl" "cdn" {
  name        = "${var.prefix}-cloudfront-acl"
  description = "Web ACL for CloudFront"
  scope       = "CLOUDFRONT"
  provider    = aws.us_east_1
  default_action {
    allow {}
  }
  dynamic "rule" {
    for_each = var.aws_managed_waf_rules
    content {
      name     = rule.key
      priority = rule.value
      override_action {
        none {}
      }
      statement {
        managed_rule_group_statement {
          name        = rule.key
          vendor_name = "AWS"
        }
      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${rule.key}Metric"
        sampled_requests_enabled   = false
      }
    }
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.prefix}-WebACL-Metric"
    sampled_requests_enabled   = false
  }
}
