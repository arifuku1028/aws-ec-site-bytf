variable "prefix" {
  type = string
}

variable "root_domain" {
  type = string
}

variable "cdn_cert_arn" {
  type = string
}

variable "s3_bucket" {
  type = object({
    id                          = string
    arn                         = string
    bucket_regional_domain_name = string
  })
}

variable "alb_id" {
  type = string
}

variable "aws_managed_waf_rules" {
  type = map(number)
}
