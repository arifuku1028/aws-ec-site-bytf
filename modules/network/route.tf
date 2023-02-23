resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.prefix}-route-public"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.prefix}-route-private"
  }
}

resource "aws_route_table" "s3_private" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.prefix}-route-s3-private"
  }
}

resource "aws_route_table_association" "alb" {
  for_each       = aws_subnet.alb
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "app" {
  for_each       = aws_subnet.app
  subnet_id      = each.value.id
  route_table_id = aws_route_table.s3_private.id
}

resource "aws_route_table_association" "db" {
  for_each       = aws_subnet.db
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "cache" {
  for_each       = aws_subnet.cache
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "vpce" {
  for_each       = aws_subnet.vpce
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
