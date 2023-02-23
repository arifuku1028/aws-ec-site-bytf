variable "prefix" {
  type = string
}

variable "alb_cert_arn" {
  type = string
}

variable "alb_subnet_ids" {
  type = list(string)
}

variable "alb_sg_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "alb_tg" {
  type = map(object({
    health_check_path = string
  }))
}

variable "rule_path_patterns" {
  type = list(string)
}

variable "default_app_name" {
  type = string
}

variable "path_based_app_name" {
  type = string
}
