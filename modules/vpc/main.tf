locals {
  name_prefix = "${var.project_name}-${terraform.workspace}"
  common_tags = {
    Project = var.project_name
    ManagedBy = "terraform"
    "kubernetes.io/cluster/${local.name_prefix}" = "shared"
  }
}

resource "aws_vpc" "main" {
  cidr_block =  var.vpc
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = merge(local.common_tags, { Name = "${local.name_prefix}-vpc" })
}

resource "aws_subnet" "public_subnets" {
  vpc_id = aws_vpc.main.id
  count = length(var.public_subnet_cidrs)
  cidr_block = var.public_subnet_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone = var.aws_azs[count.index]
  tags = merge(local.common_tags, {
    Name                     = "${local.name_prefix}-public-${count.index}"
    "kubernetes.io/role/elb" = "1"
  })
}

resource "aws_subnet" "private_subnets" {
  vpc_id = aws_vpc.main.id
  count = length(var.private_subnet_cidrs)
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone = var.aws_azs[count.index]
  tags = merge(local.common_tags, {
    Name                              = "${local.name_prefix}-private-${count.index}"
    "kubernetes.io/role/internal-elb" = "1"
  })
}

# --- Gateways ---
resource "aws_internet_gateway" "igw"{
  vpc_id = aws_vpc.main.id
  tags = merge(local.common_tags, { Name = "${local.name_prefix}-igw"})

}

resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = merge(local.common_tags, { Name = "${local.name_prefix}-nat-eip" })
}



resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  # count = length(var.private_subnet_cidrs)
  # NAT must live in a PUBLIC subnet to reach the IGW
  subnet_id = aws_subnet.public_subnets[0].id
  depends_on = [ aws_internet_gateway.igw ]
}

# --- Routing ---

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(local.common_tags, { Name = "${local.name_prefix}-public-rt" })
}
  
# Provides a resource to create an association between a route table and a subnet or a route table and an internet gateway or virtual private gateway.
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)
  subnet_id = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public.id
}

#private subnets route to NAT
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
  tags = merge(local.common_tags, { Name = "${local.name_prefix}-private-rt" })
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)
  subnet_id = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private.id
}