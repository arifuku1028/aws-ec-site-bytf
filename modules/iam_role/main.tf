locals {
  policy_map = {
    "s3" = {
      name   = "EditStaticContentsS3Bucket"
      policy = data.aws_iam_policy_document.edit_static_bucket.json
    },
    "secretsmanager" = {
      name   = "GetDBSecret"
      policy = data.aws_iam_policy_document.get_db_secret.json
    }
  }
}

data "aws_iam_policy_document" "get_db_secret" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      "${var.db_secret_arn}"
    ]
  }
}

data "aws_iam_policy_document" "edit_static_bucket" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = [
      "${var.static_bucket_arn}",
      "${var.static_bucket_arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "ec2_assume_role_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "app" {
  for_each           = var.apps
  name               = "${var.prefix}-${each.key}-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_trust.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
  dynamic "inline_policy" {
    for_each = toset(each.value.allow_access_to)
    content {
      name   = local.policy_map["${inline_policy.value}"].name
      policy = local.policy_map["${inline_policy.value}"].policy
    }
  }
}
