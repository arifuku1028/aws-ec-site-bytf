variable "prefix" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "region" {
  type = string
}

variable "az_map" {
  type = map(number)
  default = {
    "ap-northeast-1a" = 1,
    "ap-northeast-1c" = 2,
  }
}

variable "vpce_service" {
  type = list(string)
}

variable "apps" {
  type = map(object({
    description = string
  }))
}
