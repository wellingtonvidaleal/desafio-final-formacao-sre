#Define o grupo de segurança
resource "aws_security_group" "bastion_host" {
  name        = "bastion_host"
  description = "Definicao de acessos do bastion host"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "SSH de fora para dentro"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    description = "Saida para qualquer IP em qualquer porta"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion_host"
  }
}

#Define o EC2 bastion host que acessará os outros EC2
resource "aws_instance" "bastion_host" {
  ami                         = var.ami_wordpress
  instance_type               = var.instance_type
  key_name                    = var.ssh_key
  monitoring                  = true
  vpc_security_group_ids      = [aws_security_group.bastion_host.id]
  subnet_id                   = aws_subnet.public_az_a.id
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    sudo apt update && sudo apt install curl -y

  EOF

  tags = {
    Name = "bastion_host"
  }
}