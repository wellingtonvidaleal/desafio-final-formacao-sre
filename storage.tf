resource "aws_security_group" "storage" {
  name        = "storage"
  description = "Definicao de acessos do armazenamento"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "Todo trafego de subredes privadas onde estao os servidores web para dentro"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.subnet_private_az_a_cidr_block, var.subnet_private_az_b_cidr_block]
  }

  tags = {
    Name = "storage"
  }
}

resource "aws_efs_file_system" "this" {
  creation_token   = "desafio-final-formacao-sre-wellington-vida-leal"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = "true"

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    Name = "storage"
  }
}

resource "aws_efs_mount_target" "this" {
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = aws_subnet.private_az_a.id
  security_groups = ["${aws_security_group.storage.id}"]
}

resource "aws_efs_backup_policy" "policy" {
  file_system_id = aws_efs_file_system.this.id

  backup_policy {
    status = "DISABLED"
  }
}

resource "aws_efs_access_point" "this" {
  file_system_id = aws_efs_file_system.this.id
}