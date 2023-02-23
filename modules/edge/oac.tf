resource "aws_cloudfront_origin_access_control" "s3" {
  name                              = "${var.prefix}-cloudfront-oac"
  description                       = "Origin Access Control for S3 Origin"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_s3_bucket_policy" "static" {
  bucket = var.s3_bucket.id
  policy = data.aws_iam_policy_document.static_bucket_policy.json
}

data "aws_iam_policy_document" "static_bucket_policy" {
  statement {
    actions = ["s3:GetObject"]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    resources = ["${var.s3_bucket.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["${aws_cloudfront_distribution.cdn.arn}"]
    }
  }
}
