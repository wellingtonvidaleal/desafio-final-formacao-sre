#Define a VPC
resource "aws_vpc" "VPC-Desafio-Final" {
  cidr_block           = var.vpcCIDRblock
  instance_tenancy     = var.vpcInstanceTenancy 
  enable_dns_support   = var.vpcDnsSupport 
  enable_dns_hostnames = var.vpcDnsHostNames
  tags = {
    Name = "VPC-Desafio-Final"
  }
}

#Define as sub-redes
resource "aws_subnet" "Pub-AZ-A" {
  vpc_id                  = aws_vpc.VPC-Desafio-Final.id
  cidr_block              = var.subnetPub-AZ-ACIDRblock
  map_public_ip_on_launch = var.mapPublicIPPublicas
  availability_zone       = var.availabilityZoneA
  tags = {
    Name = "Pub-AZ-A"
  }
}

resource "aws_subnet" "Pub-AZ-B" {
  vpc_id                  = aws_vpc.VPC-Desafio-Final.id
  cidr_block              = var.subnetPub-AZ-BCIDRblock
  map_public_ip_on_launch = var.mapPublicIPPublicas
  availability_zone       = var.availabilityZoneB
  tags = {
    Name = "Pub-AZ-B"
  }
}

resource "aws_subnet" "Priv-AZ-A" {
  vpc_id                  = aws_vpc.VPC-Desafio-Final.id
  cidr_block              = var.subnetPriv-AZ-ACIDRblock
  map_public_ip_on_launch = var.mapPublicIPPrivadas
  availability_zone       = var.availabilityZoneA
  tags = {
    Name = "Priv-AZ-A"
  }
}

resource "aws_subnet" "Priv-AZ-B" {
  vpc_id                  = aws_vpc.VPC-Desafio-Final.id
  cidr_block              = var.subnetPriv-AZ-BCIDRblock
  map_public_ip_on_launch = var.mapPublicIPPrivadas
  availability_zone       = var.availabilityZoneB
  tags = {
    Name = "Priv-AZ-B"
  }
}

#Define o Gateway de Internet
resource "aws_internet_gateway" "Internet-Gateway-Desafio-Final" {
  vpc_id = aws_vpc.VPC-Desafio-Final.id
  tags = {
    Name = "Internet-Gateway-Desafio-Final"
  }
}

#Define tabela de rotas "Publicas"
resource "aws_route_table" "Publicas" {
  vpc_id = aws_vpc.VPC-Desafio-Final.id

  route {
    cidr_block = var.ipsDeDestinosPublicosCIDRblock
    gateway_id = aws_internet_gateway.Internet-Gateway-Desafio-Final.id
  }

  tags = {
    Name = "Publicas"
  }
}

#Associa tabela de rotas "Publica" às sub-redes públicas
resource "aws_route_table_association" "Associacao-Pub-AZ-A-Publicas" {
  subnet_id = aws_subnet.Pub-AZ-A.id
  route_table_id = aws_route_table.Publicas.id
}

resource "aws_route_table_association" "Associacao-Pub-AZ-B-Publicas" {
  subnet_id = aws_subnet.Pub-AZ-B.id
  route_table_id = aws_route_table.Publicas.id
}

#Aloca IP elástico para a VNC
resource "aws_eip" "Elastic-IP" {
  vpc = true
  
  depends_on = [  ]
}

#Define o Gateway NAT
resource "aws_nat_gateway" "Gateway-NAT" {
  allocation_id = aws_eip.Elastic-IP.id
  subnet_id = aws_subnet.Priv-AZ-A.id
  depends_on = [
    aws_internet_gateway.Internet-Gateway-Desafio-Final
  ]
}

#Define tabela de rotas "Privadas"
resource "aws_route_table" "Privadas" {
  vpc_id = aws_vpc.VPC-Desafio-Final.id

  route {
    cidr_block = var.ipsDeDestinosPublicosCIDRblock
    gateway_id = aws_nat_gateway.Gateway-NAT.id
  }

  tags = {
    Name = "Privadas"
  }
}

#Associa tabela de rotas "Privada" às sub-redes privadas
resource "aws_route_table_association" "Associacao-Priv-AZ-A-Privadas" {
  subnet_id = aws_subnet.Priv-AZ-A.id
  route_table_id = aws_route_table.Privadas.id
}

resource "aws_route_table_association" "Associacao-Priv-AZ-B-Privadas" {
  subnet_id = aws_subnet.Priv-AZ-B.id
  route_table_id = aws_route_table.Privadas.id
}