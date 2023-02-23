variable "prefix" {
  type = string
}

variable "asg_subnet_ids" {
  type = list(string)
}

variable "asg" {
  type = map(object({
    sg_ids              = list(string)
    role_name           = string
    target_group_arns   = list(string)
    desired_capacity    = number
    min_size            = number
    max_size            = number
    enable_scale_policy = bool
    image_id            = string
    instance_type       = string
    device_name         = string
    volume_type         = string
    volume_size         = number
    volume_encrypted    = bool
    user_data           = string
  }))
}
