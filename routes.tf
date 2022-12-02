#Define tabela de rotas "Publicas"
resource "aws_default_route_table" "publics" {
  default_route_table_id = aws_vpc.this.default_route_table_id

  tags = {
    Name = "publics"
  }
}

resource "aws_route" "public_default" {
  route_table_id = aws_default_route_table.publics.id

  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

#Associa tabela de rotas "Publica" às sub_redes públicas
resource "aws_route_table_association" "association_public_az_a_publics" {
  subnet_id      = aws_subnet.public_az_a.id
  route_table_id = aws_default_route_table.publics.id
}

resource "aws_route_table_association" "association_public_az_b_publics" {
  subnet_id      = aws_subnet.public_az_b.id
  route_table_id = aws_default_route_table.publics.id
}

#Define tabela de rotas "Privadas"
resource "aws_route_table" "privates" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "privates"
  }
}

resource "aws_route" "private_default" {
  route_table_id = aws_route_table.privates.id

  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

#Associa tabela de rotas "Privada" às sub_redes privadas
resource "aws_route_table_association" "association_private_az_a_privates" {
  subnet_id      = aws_subnet.private_az_a.id
  route_table_id = aws_route_table.privates.id
}

resource "aws_route_table_association" "association_private_az_b_privates" {
  subnet_id      = aws_subnet.private_az_b.id
  route_table_id = aws_route_table.privates.id
}