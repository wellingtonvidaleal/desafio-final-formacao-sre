resource "aws_security_group" "elasticache" {
  name        = "elasticache"
  description = "Definicao de acesso ao servico de Elasticache"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "Libera entrada na porta do Elasticache para os servidores web que estao nas subredes publicas"
    from_port   = 11211
    to_port     = 11211
    protocol    = "tcp"
    cidr_blocks = [var.subnet_public_az_a_cidr_block, var.subnet_public_az_b_cidr_block]
  }

  tags = {
    Name = "elasticache"
  }
}
