#Define o grupo de sub-rede do banco
resource "aws_db_subnet_group" "this" {
  name       = "db_subnet_group"
  subnet_ids = [aws_subnet.private_az_a.id, aws_subnet.private_az_b.id]

  tags = merge(local.wordpress_tags,
    {
      Name = "${var.environment}-databases"
    }
  )
}

#Define o security group do banco
resource "aws_security_group" "databases" {
  name        = "databases"
  description = "Definicao de acessos dos servidores de bancos de dados"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "Libera entrada na porta do MySQL para os servidores web que estao nas subredes privadas)"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.wordpress.id]
  }

  tags = merge(local.wordpress_tags,
    {
      Name = "${var.environment}-databases"
    }
  )
}

#Define o banco de dados MySQL que será utilizado pelo Wordpress
resource "aws_db_instance" "this" {
  identifier             = "wordpress"
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "5.7.40"
  instance_class         = var.instance_class
  db_name                = "wordpress"
  username               = "wpuser"
  password               = "roZ9922XrOKnIv8mMf1laJzs2yQ7x8"
  db_subnet_group_name   = aws_db_subnet_group.this.id
  multi_az               = true
  vpc_security_group_ids = [aws_security_group.databases.id]
  skip_final_snapshot    = true
  #backup_retention_period = 7

  tags = local.wordpress_tags
}