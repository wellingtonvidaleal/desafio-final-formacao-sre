#Define os grupos de segurança
resource "aws_security_group" "load_balance" {
  name        = "load_balance"
  description = "Definicao de acessos dos balanceador de carga"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "HTTP de fora para dentro"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.all_ips_cidr_block]
  }

  ingress {
    description = "HTTPS de fora para dentro"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.all_ips_cidr_block]
  }

  egress {
    description = "Saida para as redes interna publicas da VPC na porta 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.subnet_private_az_a_cidr_block, var.subnet_private_az_b_cidr_block]
  }

  egress {
    description = "Saida para as redes interna publicas da VPC na porta 443"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.subnet_private_az_a_cidr_block, var.subnet_private_az_b_cidr_block]
  }

  tags = {
    Name = "load_balance"
  }
}

