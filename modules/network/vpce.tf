resource "aws_vpc_endpoint" "s3" {
  service_name = "com.amazonaws.${var.region}.s3"
  vpc_id       = aws_vpc.main.id
  tags = {
    Name = "${var.prefix}-s3-vpce"
  }
}

resource "aws_vpc_endpoint_route_table_association" "s3" {
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  route_table_id  = aws_route_table.s3_private.id
}

resource "aws_vpc_endpoint" "interface" {
  for_each            = toset(var.vpce_service)
  service_name        = "com.amazonaws.${var.region}.${each.value}"
  vpc_id              = aws_vpc.main.id
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [for subnet in aws_subnet.vpce : subnet.id]
  security_group_ids  = [aws_security_group.vpce.id]
  tags = {
    Name = "${var.prefix}-${each.value}-vpce"
  }
}
