#Definição do security group do elasticache
resource "aws_security_group" "sessions" {
  name        = "sessions"
  description = "Definicao de acesso ao servico de Elasticache"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "Libera entrada na porta do Elasticache para os servidores web que estao nas subredes privadas"
    from_port       = 11211
    to_port         = 11211
    protocol        = "tcp"
    security_groups = [aws_security_group.wordpress.id]
  }

  tags = merge(local.wordpress_tags,
    {
      Name = "${var.environment}-sessions"
    }
  )
}

#Definição do grupo de sub-rede do elasticache
resource "aws_elasticache_subnet_group" "this" {
  name       = "elasticache"
  subnet_ids = [aws_subnet.private_az_a.id, aws_subnet.private_az_b.id]

  tags = merge(local.wordpress_tags,
    {
      Name = "${var.environment}-sessions"
    }
  )
}

#Definição do cluster do Elasticache cross-az
resource "aws_elasticache_cluster" "this" {
  cluster_id                   = "sessions"
  engine                       = "memcached"
  node_type                    = var.node_type
  num_cache_nodes              = 2
  parameter_group_name         = "default.memcached1.6"
  port                         = 11211
  az_mode                      = "cross-az"
  preferred_availability_zones = []
  apply_immediately            = true
  subnet_group_name            = aws_elasticache_subnet_group.this.name

  tags = merge(local.wordpress_tags,
    {
      Name = "${var.environment}-sessions"
    }
  )
}