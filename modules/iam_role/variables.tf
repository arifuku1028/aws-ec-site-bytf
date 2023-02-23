variable "prefix" {
  type = string
}

variable "static_bucket_arn" {
  type = string
}

variable "db_secret_arn" {
  type = string
}

variable "apps" {
  type = map(object({
    allow_access_to = list(string)
  }))
}
