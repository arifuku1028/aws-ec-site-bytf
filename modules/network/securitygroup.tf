data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

resource "aws_security_group" "alb" {
  description = "SecurityGroup for ALB"
  vpc_id      = aws_vpc.main.id
  name        = "${var.prefix}-sg-alb"
  tags = {
    Name = "${var.prefix}-sg-alb"
  }
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    prefix_list_ids = [data.aws_ec2_managed_prefix_list.cloudfront.id]
  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
}

resource "aws_security_group" "app" {
  for_each    = var.apps
  description = "SecurityGroup for ${each.value.description}"
  vpc_id      = aws_vpc.main.id
  name        = "${var.prefix}-sg-${each.key}"
  tags = {
    Name = "${var.prefix}-sg-${each.key}"
  }
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db" {
  description = "SecurityGroup for Database Server"
  vpc_id      = aws_vpc.main.id
  name        = "${var.prefix}-sg-db"
  tags = {
    Name = "${var.prefix}-sg-db"
  }
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [for sg in aws_security_group.app : sg.id]
  }
}

resource "aws_security_group" "cache" {
  description = "SecurityGroup for Cache Server"
  vpc_id      = aws_vpc.main.id
  name        = "${var.prefix}-sg-cache"
  tags = {
    Name = "${var.prefix}-sg-cache"
  }
  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [for sg in aws_security_group.app : sg.id]
  }
}

resource "aws_security_group" "vpce" {
  description = "SecurityGroup for VPC Endpoint"
  vpc_id      = aws_vpc.main.id
  name        = "${var.prefix}-sg-vpce"
  tags = {
    Name = "${var.prefix}-sg-vpce"
  }
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [for sg in aws_security_group.app : sg.id]
  }
}
