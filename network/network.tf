resource "aws_vpc" "vpc" {
  cidr_block           = "${var.cidr_prefix}.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name     = "${var.platform}-vpc"
    Project  = "demo"
    Platform = "${var.platform}"
    Role     = "networking"
  }
}

# SUBNET Bastion
resource "aws_subnet" "bastion_subnet" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.cidr_prefix}.1.0/28" # (x.x.1.0 - x.x.1.14)
  availability_zone = "${var.region}a"

  tags = {
    Name     = "bastion"
    Project  = "demo"
    Platform = "${var.platform}"
    Role     = "networking"
  }
}

# SUBNET Instance
resource "aws_subnet" "instance_subnet" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.cidr_prefix}.1.16/28" # (x.x.1.16 - x.x.1.29)
  availability_zone = "${var.region}a"

  tags = {
    Name     = "instance"
    Project  = "demo"
    Platform = "${var.platform}"
    Role     = "networking"
  }
}

# Internet GATEWAY
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"
}

# Route
resource "aws_route" "igw_route" {
  route_table_id         = "${aws_route_table.default_route_table.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw.id}"
}

# ROUTE TABLES

resource "aws_route_table" "default_route_table" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name     = "default route table"
    Project  = "demo"
    Platform = "${var.platform}"
    Role     = "networking"
  }
}

# Route table association
resource "aws_route_table_association" "public-to-bastion" {
  subnet_id      = "${aws_subnet.bastion_subnet.id}"
  route_table_id = "${aws_route_table.default_route_table.id}"
}

resource "aws_route_table_association" "public-to-server" {
  subnet_id      = "${aws_subnet.instance_subnet.id}"
  route_table_id = "${aws_route_table.default_route_table.id}"
}
