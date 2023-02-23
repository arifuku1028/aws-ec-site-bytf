resource "aws_cloudfront_distribution" "cdn" {
  enabled    = true
  aliases    = ["${var.root_domain}"]
  web_acl_id = aws_wafv2_web_acl.cdn.arn

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = var.cdn_cert_arn
    minimum_protocol_version       = "TLSv1"
    ssl_support_method             = "sni-only"
  }

  origin {
    domain_name = "alb.${var.root_domain}"
    origin_id   = var.alb_id
    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "https-only"
      origin_read_timeout      = 60
      origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  origin {
    domain_name              = var.s3_bucket.bucket_regional_domain_name
    origin_id                = var.s3_bucket.id
    origin_access_control_id = aws_cloudfront_origin_access_control.s3.id
  }

  default_cache_behavior {
    target_origin_id       = var.alb_id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    forwarded_values {
      query_string = true
      headers      = ["*"]
      cookies {
        forward = "all"
      }
    }
    min_ttl     = 0
    default_ttl = 10
    max_ttl     = 60
  }

  ordered_cache_behavior {
    target_origin_id       = var.alb_id
    path_pattern           = "/manage/*"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    compress               = true
    forwarded_values {
      query_string = true
      headers      = ["*"]
      cookies {
        forward = "all"
      }
    }
  }

  ordered_cache_behavior {
    target_origin_id       = var.s3_bucket.id
    path_pattern           = "/static/*"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    forwarded_values {
      query_string = false
      headers      = ["Origin"]
      cookies {
        forward = "none"
      }
    }
    min_ttl     = 0
    default_ttl = 300
    max_ttl     = 600
    compress    = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["JP"]
    }
  }
}
