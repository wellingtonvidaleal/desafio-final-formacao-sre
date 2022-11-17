#Set the VPC
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = var.vpc_instance_tenancy
  enable_dns_support   = var.vpc_dns_support
  enable_dns_hostnames = var.vpc_dns_host_names

  tags = {
    Name = "vpc_desafio_final"
  }
}

#Set subnets
resource "aws_subnet" "public_az_a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.subnet_private_az_a_cidr_block
  map_public_ip_on_launch = var.map_public_ip_publics
  availability_zone       = var.availability_zone_a

  tags = {
    Name = "public_az_a"
  }
}

resource "aws_subnet" "public_az_b" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.subnet_public_az_b_cidr_block
  map_public_ip_on_launch = var.map_public_ip_publics
  availability_zone       = var.availability_zone_b

  tags = {
    Name = "public_az_b"
  }
}

resource "aws_subnet" "private_az_a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.subnet_private_az_a_cidr_block
  map_public_ip_on_launch = var.map_public_ip_privates
  availability_zone       = var.availability_zone_a

  tags = {
    Name = "private_az_a"
  }
}

resource "aws_subnet" "private_az_b" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.subnet_private_az_b_cidr_block
  map_public_ip_on_launch = var.map_public_ip_privates
  availability_zone       = var.availability_zone_b

  tags = {
    Name = "private_az_b"
  }
}

#Set the internet gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "internet_gateway_desafio_final"
  }
}

#Alocate elastic IP elástico for the VPC
resource "aws_eip" "this" {
  vpc = true
}

#Set NAT gateway
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.this.id
  subnet_id     = aws_subnet.private_az_a.id
  depends_on = [
    aws_internet_gateway.this
  ]
}
