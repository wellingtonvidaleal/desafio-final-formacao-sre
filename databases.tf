locals {
  db_instance_class = "db.${var.instance_type}"
}

resource "aws_db_subnet_group" "this" {
  name       = "db_subnet_group"
  subnet_ids = [aws_subnet.private_az_a.id, aws_subnet.private_az_b.id]
}

resource "aws_security_group" "databases" {
  name        = "databases"
  description = "Definicao de acessos dos servidores de bancos de dados"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "Libera entrada na porta do MySQL para os servidores web que estao nas subredes publicas)"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    #Trocar por subnets privadas após implementar o load balance
    cidr_blocks = [var.subnet_public_az_a_cidr_block, var.subnet_public_az_b_cidr_block]
  }

  tags = {
    Name = "databases"
  }
}

#Define o banco de dados MySQL
resource "aws_db_instance" "this" {
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "5.7.40"
  instance_class         = local.db_instance_class
  db_name                = "wordpress"
  username               = "wpuser"
  password               = "roZ9922XrOKnIv8mMf1laJzs2yQ7x8"
  db_subnet_group_name   = aws_db_subnet_group.this.id
  multi_az               = true
  vpc_security_group_ids = [aws_security_group.databases.id]
  skip_final_snapshot    = true
  #backup_retention_period = 7
}

resource "local_file" "db_endpoint" {
  content  = aws_db_instance.this.address
  filename = "${path.module}/endpoint_do_banco_mysql.txt"
}