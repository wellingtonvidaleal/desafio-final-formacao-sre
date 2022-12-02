#Define o grupo de segurança
resource "aws_security_group" "load_balance" {
  name        = "load_balance"
  description = "Definicao de acessos dos balanceador de carga"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "HTTP de fora para dentro"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS de fora para dentro"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Saida para qualquer IP em qualquer porta"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "load_balance"
  }
}

resource "aws_lb" "this" {
  name                       = "wordpress"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.load_balance.id]
  subnets                    = [aws_subnet.public_az_a.id, aws_subnet.public_az_b.id]
  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

# resource "aws_lb_listener" "http" {
#   load_balancer_arn = aws_lb.this.arn
#   protocol          = "TCP"
#   port              = 80

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.http.arn
#   }
# }

# resource "aws_lb_target_group" "http" {
#   port     = 80
#   protocol = "TCP"
#   vpc_id   = aws_vpc.this.id

#   /* health_check {
#     enabled = true
#     path     = "/"
#     port     = "80"
#     protocol = "HTTP"
#   } */

#   /* depends_on = [
#     aws_lb.this
#   ] */
# }

# resource "tls_private_key" "this" {
#   algorithm = "RSA"
# }

# resource "tls_self_signed_cert" "this" {
#   key_algorithm   = "RSA"
#   private_key_pem = tls_private_key.this.private_key_pem

#   subject {
#     common_name  = "example.com"
#     organization = "ACME Examples, Inc"
#   }

#   validity_period_hours = 87600

#   allowed_uses = [
#     "key_encipherment",
#     "digital_signature",
#     "server_auth",
#   ]
# }

# resource "aws_acm_certificate" "this" {
#   private_key      = tls_private_key.this.private_key_pem
#   certificate_body = tls_self_signed_cert.this.cert_pem
# }

# resource "aws_lb_listener" "https" {
#   load_balancer_arn = aws_lb.this.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"

#   # TODO: criar certificado válido
#   certificate_arn   = aws_acm_certificate.this.arn

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.https.arn
#   }
# }

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  protocol          = "HTTPS"
  port              = 443

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.https.arn
  }
}

resource "aws_lb_target_group" "https" {
  port     = 443
  protocol = "TCP"
  vpc_id   = aws_vpc.this.id

  health_check {
    enabled  = true
    path     = "/"
    port     = "443"
    protocol = "HTTPS"
  }

  /*   depends_on = [
    aws_lb.this
  ] */
}