provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
  default_tags {
    tags = {
      aws-exam-resource = true
    }
  }
}

data "aws_route53_zone" "main" {
  name         = var.zone_name
  private_zone = false
}

resource "aws_route53_record" "alb" {
  zone_id = data.aws_route53_zone.main.id
  name    = "alb.${data.aws_route53_zone.main.name}"
  type    = "A"
  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "cdn" {
  zone_id = data.aws_route53_zone.main.id
  name    = data.aws_route53_zone.main.name
  type    = "A"
  alias {
    name                   = var.cdn_dns_name
    zone_id                = var.cdn_zone_id
    evaluate_target_health = true
  }
}

resource "aws_acm_certificate" "alb" {
  domain_name               = data.aws_route53_zone.main.name
  subject_alternative_names = ["*.${data.aws_route53_zone.main.name}"]
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate" "cdn" {
  domain_name               = data.aws_route53_zone.main.name
  subject_alternative_names = ["*.${data.aws_route53_zone.main.name}"]
  validation_method         = "DNS"
  provider                  = aws.us_east_1
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation_alb" {
  for_each = {
    for dvo in aws_acm_certificate.alb.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type
  ttl             = "300"
  zone_id         = data.aws_route53_zone.main.id
}

resource "aws_route53_record" "cert_validation_cdn" {
  for_each = {
    for dvo in aws_acm_certificate.cdn.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type
  ttl             = "300"
  zone_id         = data.aws_route53_zone.main.id
}
