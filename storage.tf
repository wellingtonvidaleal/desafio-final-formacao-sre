#Defini o security group do EFS
resource "aws_security_group" "storage" {
  name        = "storage"
  description = "Definicao de acessos do armazenamento"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "Todo trafego de subredes privadas onde estao os servidores web para dentro"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.wordpress.id]
  }

  tags = merge(local.wordpress_tags,
    {
      Name = "${var.environment}-storage"
    }
  )
}

#Define o EFS
resource "aws_efs_file_system" "this" {
  creation_token   = "desafio-final-formacao-sre-wellington-vida-leal"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = "true"

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = merge(local.wordpress_tags,
    {
      Name = "${var.environment}-storage"
    }
  )
}

#Define o ponto de montagem do EFS na sub-rede privada
resource "aws_efs_mount_target" "this" {
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = aws_subnet.private_az_a.id
  security_groups = ["${aws_security_group.storage.id}"]
}

#Desabilita a política de backup
resource "aws_efs_backup_policy" "policy" {
  file_system_id = aws_efs_file_system.this.id

  backup_policy {
    status = "DISABLED"
  }
}

#Define o ponto de acesso do EFS
resource "aws_efs_access_point" "this" {
  file_system_id = aws_efs_file_system.this.id

  tags = merge(local.wordpress_tags,
    {
      Name = "${var.environment}-storage"
    }
  )
}