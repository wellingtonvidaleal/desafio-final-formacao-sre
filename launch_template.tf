resource "aws_security_group" "wordpress" {
  name        = "wordpress"
  description = "Definicao de acessos dos servidores de aplicacao do Wordpress"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "Conexoes do bastion host"
    from_port       = 0
    to_port         = 0
    protocol        = -1
    security_groups = [aws_security_group.bastion_host.id]
  }

  ingress {
    description     = "HTTP de fora para dentro"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balance.id]
  }

  ingress {
    description     = "HTTPS de fora para dentro"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balance.id]
  }

  egress {
    description = "Saida para qualquer IP em qualquer porta"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wordpress"
  }
}

# data "template_file" "this" {
#   template = <<-EOF
#     #!/bin/bash
#     sudo apt update && sudo apt install git curl ansible unzip -y
#     cd /tmp
#     git clone https://github.com/wellingtonvidaleal/ansible-desafio-final-formacao-sre.git
#     cd ansible-desafio-final-formacao-sre

#     sudo ansible-playbook wordpress.yml \
#       --inventory 'localhost,' \
#       --connection local \
#       --extra-vars "wordpress_db_host=${aws_db_instance.this.address}" \
#       --extra-vars "wordpress_db_name=${aws_db_instance.this.db_name}" \
#       --extra-vars "wordpress_db_username=${aws_db_instance.this.username}" \
#       --extra-vars "wordpress_db_password=${aws_db_instance.this.password}" \
#       --extra-vars "file_system_id=${aws_efs_file_system.this.id}" \
#       --extra-vars "aws_region=${var.region}" \
#       --extra-vars "session_save_path=${aws_elasticache_cluster.this.configuration_endpoint}"

#     sudo mount -a
#   EOF
# }

locals {
  user_data = templatefile(
    "${path.module}/templates/user_data.tftpl",
    {
      wordpress_db_host     = aws_db_instance.this.address
      wordpress_db_name     = aws_db_instance.this.db_name
      wordpress_db_username = aws_db_instance.this.username
      wordpress_db_password = aws_db_instance.this.password
      file_system_id        = aws_efs_file_system.this.id
      aws_region            = var.region
      session_save_path     = aws_elasticache_cluster.this.configuration_endpoint
    }
  )
}

resource "aws_launch_template" "this" {
  #disable_api_termination = true
  image_id                             = var.ami_wordpress
  instance_initiated_shutdown_behavior = "terminate"
  instance_type                        = var.instance_type
  key_name                             = var.ssh_key
  vpc_security_group_ids               = [aws_security_group.wordpress.id]

  user_data = base64encode(local.user_data)

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "wordpress"
    }
  }
}