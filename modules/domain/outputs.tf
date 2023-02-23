output "alb_cert_arn" {
  value = aws_acm_certificate.alb.arn
}

output "cdn_cert_arn" {
  value = aws_acm_certificate.cdn.arn
}
