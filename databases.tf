#Define o banco de dados MySQL
resource "aws_db_instance" "BancoDeDadosWordpress" {
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "5.7.40"
  instance_class         = "db.t3.micro"
  db_name                = "BancoDeDados"
  username               = "wordpress"
  password               = "roZ9922XrOKnIv8mMf1laJzs2yQ7x8"
  db_subnet_group_name   = aws_db_subnet_group.dbSubrede.id
  multi_az               = true
  vpc_security_group_ids = [aws_security_group.BancosDeDados.id]
  skip_final_snapshot    = true
  #backup_retention_period = 7
}

resource "aws_db_subnet_group" "dbSubrede" {
  name       = "db_grupo_subredes"
  subnet_ids = [aws_subnet.Priv-AZ-A.id, aws_subnet.Priv-AZ-B.id]
}