variable "prefix" {
  type = string
}

variable "az" {
  type = list(string)
}

variable "subnet_ids" {
  type = list(string)
}

variable "sg_ids" {
  type = list(string)
}

variable "engine_version" {
  type    = string
  default = "8.0.mysql_aurora.3.02.0"
}

variable "master_username" {
  type = string
}

variable "master_password" {
  type = string
}

variable "serverlessv2_min_capacity" {
  type = number
  validation {
    condition     = var.serverlessv2_min_capacity >= 0.5
    error_message = "The \"serverlessv2_min_capacity\" value must be 0.5 or more"
  }
}

variable "serverlessv2_max_capacity" {
  type = number
  validation {
    condition     = var.serverlessv2_max_capacity <= 128
    error_message = "The \"serverlessv2_max_capacity\" value must be 128 or less"
  }
}

variable "replica_scale_min_capacity" {
  type = number
  validation {
    condition     = var.replica_scale_min_capacity >= 0 && var.replica_scale_min_capacity <= 15
    error_message = "The \"replica_scale_min_capacity\" value must be 0 to 15"
  }
}
variable "replica_scale_max_capacity" {
  type = number
  validation {
    condition     = var.replica_scale_max_capacity >= 0 && var.replica_scale_max_capacity <= 15
    error_message = "The \"replica_scale_max_capacity\" value must be 0 to 15"
  }
}
