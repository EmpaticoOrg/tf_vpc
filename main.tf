data "aws_vpc" "core" {
  default = true
}

data "aws_route53_zone" "core" {
  name = "core."
  private_zone = true
}

resource "aws_vpc" "environment" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support   = "${var.enable_dns_support}"

  tags {
    Name = "${var.environment}"
  }
}

resource "aws_route53_zone_association" "core" {
  zone_id = "${data.aws_route53_zone.core.zone_id}"
  vpc_id = "${aws_vpc.environment.id}"
}

resource "aws_internet_gateway" "environment" {
  vpc_id = "${aws_vpc.environment.id}"

  tags {
    Name = "${var.environment}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.environment.id}"

  tags {
    Name = "${var.environment}-public"
  }
}

resource "aws_route_table" "private" {
  count  = "${length(var.private_subnets)}"
  vpc_id = "${aws_vpc.environment.id}"

  tags {
    Name = "${var.environment}-private"
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.environment.id}"
}

resource "aws_route" "private_nat_gateway" {
  count                  = "${length(var.private_subnets) * lookup(map(var.enable_nat_gateway, 1), "true", 0)}"
  route_table_id         = "${aws_route_table.private.*.id[count.index]}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.environment.*.id[count.index]}"
}

resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.environment.id}"
  cidr_block              = "${var.public_subnets[count.index]}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"

  tags {
    Name        = "${var.environment}-public-${count.index}"
    Environment = "${var.environment}"
  }

  count = "${length(var.public_subnets)}"
}

resource "aws_subnet" "private" {
  vpc_id                  = "${aws_vpc.environment.id}"
  cidr_block              = "${var.private_subnets[count.index]}"
  map_public_ip_on_launch = "false"

  tags {
    Name        = "${var.environment}-private-${count.index}"
    Environment = "${var.environment}"
  }

  count = "${length(var.private_subnets)}"
}

resource "aws_route_table_association" "private" {
  count          = "${length(var.private_subnets)}"
  subnet_id      = "${aws_subnet.private.*.id[count.index]}"
  route_table_id = "${aws_route_table.private.*.id[count.index]}"
}

resource "aws_route_table_association" "public" {
  count          = "${length(var.public_subnets)}"
  subnet_id      = "${aws_subnet.public.*.id[count.index]}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_eip" "environment" {
  count = "${length(var.public_subnets)}"

  vpc = true
}

resource "aws_nat_gateway" "environment" {
  count = "${length(var.private_subnets) * lookup(map(var.enable_nat_gateway, 1), "true", 0)}"

  allocation_id = "${aws_eip.environment.*.id[count.index]}"
  subnet_id     = "${aws_subnet.public.*.id[count.index]}"
}

resource "aws_security_group" "core" {
  name        = "core-to-${var.environment}"
  vpc_id      = "${aws_vpc.environment.id}"
  description = "Allow inbound core monitoring and bastion traffic"

  ingress {
    from_port = 5555
    to_port   = 5555
    protocol  = "udp"

    cidr_blocks = [
      "${var.vpc_cidr}",
      "${data.aws_vpc.core.cidr_block}",
    ]
  }

  ingress {
    from_port = 5555
    to_port   = 5555
    protocol  = "tcp"

    cidr_blocks = [
      "${var.vpc_cidr}",
      "${data.aws_vpc.core.cidr_block}",
    ]
  }

  ingress {
    from_port = 5514
    to_port   = 5514
    protocol  = "tcp"

    cidr_blocks = [
      "${var.vpc_cidr}",
      "${data.aws_vpc.core.cidr_block}",
    ]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "${var.vpc_cidr}",
      "${data.aws_vpc.core.cidr_block}",
    ]
  }

  ingress {
    from_port = 8300
    to_port   = 8300
    protocol  = "tcp"

    cidr_blocks = [
      "${var.vpc_cidr}",
      "${data.aws_vpc.core.cidr_block}",
    ]
  }

  ingress {
    from_port = 8301
    to_port   = 8301
    protocol  = "tcp"

    cidr_blocks = [
      "${var.vpc_cidr}",
      "${data.aws_vpc.core.cidr_block}",
    ]
  }

  ingress {
    from_port = 8301
    to_port   = 8301
    protocol  = "udp"

    cidr_blocks = [
      "${var.vpc_cidr}",
      "${data.aws_vpc.core.cidr_block}",
    ]
  }

  ingress {
    from_port = 4222
    to_port   = 4222
    protocol  = "tcp"

    cidr_blocks = [
      "${var.vpc_cidr}",
      "${data.aws_vpc.core.cidr_block}",
    ]
  }

  ingress {
    from_port = 8140
    to_port   = 8140
    protocol  = "tcp"

    cidr_blocks = [
      "${var.vpc_cidr}",
      "${data.aws_vpc.core.cidr_block}",
    ]
  }

  tags {
    Name = "core-to-${var.environment}-sg"
  }
}
