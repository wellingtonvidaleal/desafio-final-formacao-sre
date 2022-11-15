#Define a VPC
resource "aws_vpc" "VPC_Desafio_Final" {
  cidr_block           = var.vpcCIDRblock
  instance_tenancy     = var.vpcInstanceTenancy
  enable_dns_support   = var.vpcDnsSupport
  enable_dns_hostnames = var.vpcDnsHostNames
  tags = {
    Name = "VPC_Desafio_Final"
  }
}

#Define as sub_redes
resource "aws_subnet" "Pub_AZ_A" {
  vpc_id                  = aws_vpc.VPC_Desafio_Final.id
  cidr_block              = var.subnetPub_AZ_ACIDRblock
  map_public_ip_on_launch = var.mapPublicIPPublicas
  availability_zone       = var.availabilityZoneA
  tags = {
    Name = "Pub_AZ_A"
  }
}

resource "aws_subnet" "Pub_AZ_B" {
  vpc_id                  = aws_vpc.VPC_Desafio_Final.id
  cidr_block              = var.subnetPub_AZ_BCIDRblock
  map_public_ip_on_launch = var.mapPublicIPPublicas
  availability_zone       = var.availabilityZoneB
  tags = {
    Name = "Pub_AZ_B"
  }
}

resource "aws_subnet" "Priv_AZ_A" {
  vpc_id                  = aws_vpc.VPC_Desafio_Final.id
  cidr_block              = var.subnetPriv_AZ_ACIDRblock
  map_public_ip_on_launch = var.mapPublicIPPrivadas
  availability_zone       = var.availabilityZoneA
  tags = {
    Name = "Priv_AZ_A"
  }
}

resource "aws_subnet" "Priv_AZ_B" {
  vpc_id                  = aws_vpc.VPC_Desafio_Final.id
  cidr_block              = var.subnetPriv_AZ_BCIDRblock
  map_public_ip_on_launch = var.mapPublicIPPrivadas
  availability_zone       = var.availabilityZoneB
  tags = {
    Name = "Priv_AZ_B"
  }
}

#Define o Gateway de Internet
resource "aws_internet_gateway" "Internet_Gateway_Desafio_Final" {
  vpc_id = aws_vpc.VPC_Desafio_Final.id
  tags = {
    Name = "Internet_Gateway_Desafio_Final"
  }
}

#Aloca IP elástico para a VNC
resource "aws_eip" "Elastic_IP" {
  vpc = true

  depends_on = []
}

#Define o Gateway NAT
resource "aws_nat_gateway" "Gateway_NAT" {
  allocation_id = aws_eip.Elastic_IP.id
  subnet_id     = aws_subnet.Priv_AZ_A.id
  depends_on = [
    aws_internet_gateway.Internet_Gateway_Desafio_Final
  ]
}
