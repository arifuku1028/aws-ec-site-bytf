output "vpc_id" {
  value = aws_vpc.main.id
}

output "alb_subnet_ids" {
  value = [for subnet in aws_subnet.alb : subnet.id]
}

output "app_subnet_ids" {
  value = [for subnet in aws_subnet.app : subnet.id]
}

output "db_subnet_ids" {
  value = [for subnet in aws_subnet.db : subnet.id]
}

output "cache_subnet_ids" {
  value = [for subnet in aws_subnet.cache : subnet.id]
}

output "alb_sg_ids" {
  value = [aws_security_group.alb.id]
}

output "db_sg_ids" {
  value = [aws_security_group.db.id]
}

output "cache_sg_ids" {
  value = [aws_security_group.cache.id]
}

output "app_sg" {
  value = aws_security_group.app
}
