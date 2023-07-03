resource "aws_vpc" "vpc" {
  cidr_block = var.cidr
  tags       = { "Name" = format("%s", var.name) }

  enable_dns_hostnames = true
  enable_dns_support   = true
}

# ======== public subnets ========
resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 8, 2 + count.index)
  availability_zone       = var.availability_zones[count.index]
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = true
  tags = {
    "Name" = format(
      "%s-pbl-sbn-%s",
      var.name,
      var.availability_zones[count.index]
    )
  }
}

# allow access from the "outside world"
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id
}

resource "aws_eip" "gateway" {
  count      = length(var.availability_zones)
  vpc        = true
  depends_on = [aws_internet_gateway.gateway]
}

resource "aws_nat_gateway" "gateway" {
  count         = length(var.availability_zones)
  subnet_id     = element(aws_subnet.public[*].id, count.index)
  allocation_id = element(aws_eip.gateway[*].id, count.index)
}
# ======== public subnets ========


# ======== private subnets ========
resource "aws_subnet" "private" {
  count = length(var.availability_zones)

  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index)
  availability_zone = var.availability_zones[count.index]
  vpc_id            = aws_vpc.vpc.id
  tags = {
    "Name" = format(
      "%s-prv-sbn-%s",
      var.name,
      var.availability_zones[count.index]
    )
  }
}

resource "aws_route_table" "private" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.gateway[*].id, count.index)
  }

  tags = {
    "Name" = format(
      "%s-prv-rt-%s",
      var.name,
      var.availability_zones[count.index]
    )
  }
}

resource "aws_route_table_association" "private" {
  count          = length(var.availability_zones)
  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = element(aws_route_table.private[*].id, count.index)
}
# ======== private subnets ========


resource "aws_security_group" "ec2_ssh_rds" {
  name   = "${var.name}-rds-ec2-sec-gr"
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "Allows SSH traffic between RDS and EC2"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description      = "Allow all outgoing traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }

  tags = {
    Name = "${var.name}-rds-ec2-sec-gr"
  }
}

