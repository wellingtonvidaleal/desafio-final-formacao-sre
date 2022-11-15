#Define os grupos de segurança
resource "aws_security_group" "BalanceadorDeCarga" {
  name        = "BalanceadorDeCarga"
  description = "Definicao de acessos dos balanceador de carga"
  vpc_id      = aws_vpc.VPC_Desafio_Final.id

  ingress {
    description = "HTTP de fora para dentro"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.ipsDeDestinosPublicosCIDRblock]
  }

  ingress {
    description = "HTTPS de fora para dentro"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.ipsDeDestinosPublicosCIDRblock]
  }

  egress {
    description = "Saida para as redes interna publicas da VPC na porta 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.subnetPub_AZ_ACIDRblock, var.subnetPub_AZ_BCIDRblock]
  }

  egress {
    description = "Saida para as redes interna publicas da VPC na porta 443"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.subnetPub_AZ_ACIDRblock, var.subnetPub_AZ_BCIDRblock]
  }

  tags = {
    Name = "BalanceadorDeCarga"
  }
}

resource "aws_security_group" "ServidoresWeb" {
  name        = "ServidoresWeb"
  description = "Definicao de acessos dos servidores de aplicacao web"
  vpc_id      = aws_vpc.VPC_Desafio_Final.id

  ingress {
    description = "SSH de fora para dentro"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.meuIP]
  }

  ingress {
    description = "HTTP de fora para dentro"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.balanceadorDeCarga]
  }

  ingress {
    description = "HTTPS de fora para dentro"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.balanceadorDeCarga]
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
  vpc_id      = aws_vpc.VPC_Desafio_Final.id

  ingress {
    description = "Libera entrada na porta do MySQL para os servidores web que estao nas subredes publicas)"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.subnetPub_AZ_ACIDRblock, var.subnetPub_AZ_BCIDRblock]
  }

  tags = {
    Name = "BancosDeDados"
  }
}