output "id" {
  value = aws_lb.alb.id
}

output "dns_name" {
  value = aws_lb.alb.dns_name
}

output "zone_id" {
  value = aws_lb.alb.zone_id
}

output "tg"{
  value = aws_lb_target_group.app
}
