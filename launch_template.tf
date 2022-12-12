#Define o security group das instâncias EC2 do Wordpress
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
    description     = "HTTP do load balancer para dentro"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer.id]
  }

  ingress {
    description     = "HTTPS do load balancer para dentro"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer.id]
  }

  ingress {
    description     = "Aceita todas as conexoes vindas do security group prometheus na porta 9100"
    from_port       = 9100
    to_port         = 9100
    protocol        = "tcp"
    security_groups = [aws_security_group.prometheus.id]
  }

  ingress {
    description     = "Aceita todas as conexoes vindas do security group prometheus na porta 9113"
    from_port       = 9113
    to_port         = 9113
    protocol        = "tcp"
    security_groups = [aws_security_group.prometheus.id]
  }

  egress {
    description = "Saida para qualquer IP em qualquer porta"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.wordpress_tags,
    {
      Name = "${var.environment}-wordpress"
    }
  )
}

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
      wordpress_wp_home     = var.wp_home
      wordpress_wp_siteurl  = var.wp_siteurl
    }
  )
}

#Define o launch template que será utilizado pelo autoscaling para subir as instâncias EC2 do Wordpress
resource "aws_launch_template" "this" {
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

    tags = merge(local.wordpress_tags,
      {
        Name = "${var.environment}-wordpress"
      }
    )
  }
}