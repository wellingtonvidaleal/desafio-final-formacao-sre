#Define tabela de rotas "Publicas"
resource "aws_default_route_table" "Publicas" {
  default_route_table_id = aws_vpc.VPC_Desafio_Final.default_route_table_id

  route {
    cidr_block = var.ipsDeDestinosPublicosCIDRblock
    gateway_id = aws_internet_gateway.Internet_Gateway_Desafio_Final.id
  }

  tags = {
    Name = "Publicas"
  }
}

#Associa tabela de rotas "Publica" às sub_redes públicas
resource "aws_route_table_association" "Associacao_Pub_AZ_A_Publicas" {
  subnet_id      = aws_subnet.Pub_AZ_A.id
  route_table_id = aws_default_route_table.Publicas.id
}

resource "aws_route_table_association" "Associacao_Pub_AZ_B_Publicas" {
  subnet_id      = aws_subnet.Pub_AZ_B.id
  route_table_id = aws_default_route_table.Publicas.id
}

#Define tabela de rotas "Privadas"
resource "aws_route_table" "Privadas" {
  vpc_id = aws_vpc.VPC_Desafio_Final.id

  route {
    cidr_block = var.ipsDeDestinosPublicosCIDRblock
    gateway_id = aws_nat_gateway.Gateway_NAT.id
  }

  tags = {
    Name = "Privadas"
  }
}

#Associa tabela de rotas "Privada" às sub_redes privadas
resource "aws_route_table_association" "Associacao_Priv_AZ_A_Privadas" {
  subnet_id      = aws_subnet.Priv_AZ_A.id
  route_table_id = aws_route_table.Privadas.id
}

resource "aws_route_table_association" "Associacao_Priv_AZ_B_Privadas" {
  subnet_id      = aws_subnet.Priv_AZ_B.id
  route_table_id = aws_route_table.Privadas.id
}