resource "aws_security_group" "sessions" {
  name        = "sessions"
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

resource "aws_elasticache_subnet_group" "this" {
  name       = "elasticache"
  subnet_ids = [aws_subnet.private_az_a.id, aws_subnet.private_az_b.id]
}

resource "aws_elasticache_cluster" "this" {
  cluster_id           = "sessions"
  engine               = "memcached"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 2
  parameter_group_name = "default.memcached1.6"
  port                 = 11211
}