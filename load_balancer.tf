#Define os grupos de segurança
resource "aws_security_group" "load_balance" {
  name        = "load_balance"
  description = "Definicao de acessos dos balanceador de carga"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "HTTP de fora para dentro"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.all_ips_cidr_block]
  }

  ingress {
    description = "HTTPS de fora para dentro"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.all_ips_cidr_block]
  }

  egress {
    description = "Saida para as redes interna publicas da VPC na porta 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.subnet_private_az_a_cidr_block, var.subnet_private_az_b_cidr_block]
  }

  egress {
    description = "Saida para as redes interna publicas da VPC na porta 443"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.subnet_private_az_a_cidr_block, var.subnet_private_az_b_cidr_block]
  }

  tags = {
    Name = "load_balance"
  }
}

resource "aws_lb" "this" {
  name               = "wordpress"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.public_az_a.id, aws_subnet.public_az_b.id]
  //security_groups                  = [aws_security_group.load_balance.id]
  enable_cross_zone_load_balancing = true
  enable_deletion_protection       = false

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  protocol = "TCP"
  port     = 80

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.http.arn
  }
}

resource "aws_lb_target_group" "http" {
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.this.id

  health_check {
    enabled  = true
    path     = "/phpinfo.php"
    port     = "80"
    protocol = "HTTP"
  }

  depends_on = [
    aws_lb.this
  ]
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  protocol = "TCP"
  port     = 443

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.https.arn
  }
}

resource "aws_lb_target_group" "https" {
  port     = 443
  protocol = "TCP"
  vpc_id   = aws_vpc.this.id

  health_check {
    enabled  = true
    path     = "/phpinfo.php"
    port     = "443"
    protocol = "HTTPS"
  }

  depends_on = [
    aws_lb.this
  ]
}