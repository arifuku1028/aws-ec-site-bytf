resource "aws_autoscaling_group" "app" {
  for_each                  = var.asg
  name                      = "${var.prefix}-${each.key}-asg"
  desired_capacity          = each.value.desired_capacity
  max_size                  = each.value.max_size
  min_size                  = each.value.min_size
  vpc_zone_identifier       = var.asg_subnet_ids
  target_group_arns         = each.value.target_group_arns
  health_check_grace_period = 300
  health_check_type         = "ELB"
  launch_template {
    id      = aws_launch_template.app[each.key].id
    version = "$Latest"
  }
}

resource "aws_launch_template" "app" {
  for_each               = var.asg
  name                   = "${var.prefix}-${each.key}-launch-template"
  image_id               = each.value.image_id
  instance_type          = each.value.instance_type
  vpc_security_group_ids = each.value.sg_ids
  user_data              = base64encode(each.value.user_data)
  iam_instance_profile {
    arn = aws_iam_instance_profile.app[each.key].arn
  }
  block_device_mappings {
    device_name = each.value.device_name
    ebs {
      volume_type = each.value.volume_type
      volume_size = each.value.volume_size
      encrypted   = each.value.volume_encrypted
    }
  }
  monitoring {
    enabled = true
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.prefix}-${each.key}-instance"
    }
  }
}

resource "aws_iam_instance_profile" "app" {
  for_each = var.asg
  name     = "${var.prefix}-${each.key}-instance-profile"
  role     = each.value.role_name
}

resource "aws_autoscaling_policy" "cpu" {
  for_each               = var.asg
  autoscaling_group_name = aws_autoscaling_group.app[each.key].name
  name                   = "${var.prefix}-${each.key}-cpu-scale-policy"
  enabled                = each.value.enable_scale_policy
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 40.0
  }
}
