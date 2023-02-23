resource "aws_lb" "alb" {
  name               = "${var.prefix}-alb"
  load_balancer_type = "application"
  internal           = false
  subnets            = var.alb_subnet_ids
  security_groups    = var.alb_sg_ids
}

resource "aws_lb_listener" "alb" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.alb_cert_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app[var.default_app_name].arn
  }
}

resource "aws_lb_listener_rule" "path_base" {
  listener_arn = aws_lb_listener.alb.arn
  priority     = 100
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app[var.path_based_app_name].arn
  }
  condition {
    path_pattern {
      values = var.rule_path_patterns
    }
  }
}

resource "aws_lb_target_group" "app" {
  for_each = var.alb_tg
  name     = "${var.prefix}-alb-tg-${each.key}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path                = each.value.health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = 200
  }
}
