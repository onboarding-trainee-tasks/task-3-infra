resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "my-vpc"
  }
}

resource "aws_subnet" "this" {
  for_each = var.subnets

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = var.azs[(tonumber(regex("[0-9]+", each.key)) - 1) % length(var.azs)]

  map_public_ip_on_launch = each.value.type == "public"

  tags = {
    Name = "${each.key}"
    Type = "${each.value.type}"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${aws_vpc.this.tags["Name"]}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block =  "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${aws_vpc.this.tags["Name"]}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  for_each = { for k, v in aws_subnet.this : k => v if v.tags["Type"] == "public" }

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name = "${aws_vpc.this.tags["Name"]}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  for_each = { for k, v in aws_subnet.this : k => v if v.tags["Type"] == "private" }

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name = "${aws_vpc.this.tags["Name"]}-database-rt"
  }
}

resource "aws_route_table_association" "database" {
  for_each = { for k, v in aws_subnet.this : k => v if v.tags["Type"] == "database" }

  subnet_id      = each.value.id
  route_table_id = aws_route_table.database.id
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${aws_vpc.this.tags["Name"]}-eip"
  }
}

locals {
  public_subnet_keys = [
    for k, v in var.subnets :
    k if v.type == "public"
  ]
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.this[local.public_subnet_keys[0]].id

  tags = {
    Name = "${aws_vpc.this.tags["Name"]}-nat-gateway"
  }
}