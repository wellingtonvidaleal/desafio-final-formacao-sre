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

resource "aws_default_route_table" "Publicas" {
  default_route_table_id = aws_vpc.VPC-Desafio-Final.default_route_table_id

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
  route_table_id = aws_default_route_table.Publicas.id
}

resource "aws_route_table_association" "Associacao-Pub-AZ-B-Publicas" {
  subnet_id = aws_subnet.Pub-AZ-B.id
  route_table_id = aws_default_route_table.Publicas.id
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

#Define os grupos de segurança

resource "aws_security_group" "BalanceadorDeCarga" {
  name        = "BalanceadorDeCarga"
  description = "Definicao de acessos dos balanceador de carga"
  vpc_id      = aws_vpc.VPC-Desafio-Final.id

  ingress {
    description      = "HTTP de fora para dentro"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [var.ipsDeDestinosPublicosCIDRblock]
  }

  ingress {
    description      = "HTTPS de fora para dentro"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [var.ipsDeDestinosPublicosCIDRblock]
  }

  egress {
    description      = "Saida para as redes interna publicas da VPC na porta 80"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [var.subnetPub-AZ-ACIDRblock, var.subnetPub-AZ-BCIDRblock]
  }

  egress {
    description      = "Saida para as redes interna publicas da VPC na porta 443"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [var.subnetPub-AZ-ACIDRblock, var.subnetPub-AZ-BCIDRblock]
  }

  tags = {
    Name = "BalanceadorDeCarga"
  }
}

resource "aws_security_group" "ServidoresWeb" {
  name        = "ServidoresWeb"
  description = "Definicao de acessos dos servidores de aplicacao web"
  vpc_id      = aws_vpc.VPC-Desafio-Final.id

  ingress {
    description      = "SSH de fora para dentro"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.meuIP]
  }

  ingress {
    description      = "HTTP de fora para dentro"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [var.balanceadorDeCarga]
  }

  ingress {
    description      = "HTTPS de fora para dentro"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [var.balanceadorDeCarga]
  }

  egress {
    description      = "Saida para qualquer IP em qualquer porta"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.ipsDeDestinosPublicosCIDRblock]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "ServidoresWeb"
  }
}

resource "aws_security_group" "BancosDeDados" {
  name        = "BancosDeDados"
  description = "Definicao de acessos dos servidores de bancos de dados"
  vpc_id      = aws_vpc.VPC-Desafio-Final.id

  ingress {
    description      = "Libera entrada na porta do MySQL para os servidores web que estao nas subredes publicas)"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = [var.subnetPub-AZ-ACIDRblock, var.subnetPub-AZ-BCIDRblock]
  }

  tags = {
    Name = "BancosDeDados"
  }
}

#Define as primeiras máquinas de teste
/* resource "aws_instance" "Wordpress" {
  ami           = var.amiWordpress
  instance_type = "t2.micro"

  tags = {
    Name = "Wordpress"
  }
  
  subnet_id = aws_subnet.Pub-AZ-A.id
  associate_public_ip_address = true
  key_name = var.chaveSSH
  vpc_security_group_ids = [aws_security_group.ServidoresWeb.id]
} */

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  for_each = toset(["Wordpress01", "Wordpress02"])

  name = "instance-${each.key}"

  ami                    = var.amiWordpress
  instance_type          = "t2.micro"
  key_name               = var.chaveSSH
  monitoring             = false
  vpc_security_group_ids = [aws_security_group.ServidoresWeb.id]
  subnet_id              = aws_subnet.Pub-AZ-A.id
  associate_public_ip_address = true

  tags = {
    Name        = "${each.key}"
    Environment = "test"
  }
}

#Define o banco de dados MySQL
