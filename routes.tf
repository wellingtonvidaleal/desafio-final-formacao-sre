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
  subnet_id      = aws_subnet.Pub-AZ-A.id
  route_table_id = aws_default_route_table.Publicas.id
}

resource "aws_route_table_association" "Associacao-Pub-AZ-B-Publicas" {
  subnet_id      = aws_subnet.Pub-AZ-B.id
  route_table_id = aws_default_route_table.Publicas.id
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
  subnet_id      = aws_subnet.Priv-AZ-A.id
  route_table_id = aws_route_table.Privadas.id
}

resource "aws_route_table_association" "Associacao-Priv-AZ-B-Privadas" {
  subnet_id      = aws_subnet.Priv-AZ-B.id
  route_table_id = aws_route_table.Privadas.id
}