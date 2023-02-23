resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    Name = "${var.prefix}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.prefix}-igw"
  }
}

resource "aws_subnet" "alb" {
  for_each          = var.az_map
  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, each.value + 10)
  tags = {
    Name = "${var.prefix}-subnet-alb-${substr(each.key, -2, 2)}"
  }
}

resource "aws_subnet" "app" {
  for_each          = var.az_map
  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, each.value + 20)
  tags = {
    Name = "${var.prefix}-subnet-app-${substr(each.key, -2, 2)}"
  }
}

resource "aws_subnet" "db" {
  for_each          = var.az_map
  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, each.value + 30)
  tags = {
    Name = "${var.prefix}-subnet-db-${substr(each.key, -2, 2)}"
  }
}

resource "aws_subnet" "cache" {
  for_each          = var.az_map
  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, each.value + 40)
  tags = {
    Name = "${var.prefix}-subnet-cache-${substr(each.key, -2, 2)}"
  }
}

resource "aws_subnet" "vpce" {
  for_each          = var.az_map
  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, each.value + 50)
  tags = {
    Name = "${var.prefix}-subnet-vpce-${substr(each.key, -2, 2)}"
  }
}
