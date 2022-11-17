locals {
  ssh_user         = "ubuntu"
  key_name         = "devops"
  private_key_path = "./devops.pem"
}

resource "aws_security_group" "webservers" {
  name        = "webservers"
  description = "Definicao de acessos dos servidores de aplicacao web"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "SSH de fora para dentro"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description = "HTTP de fora para dentro"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.subnet_public_az_a_cidr_block, var.subnet_public_az_b_cidr_block]
  }

  ingress {
    description = "HTTPS de fora para dentro"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.subnet_public_az_a_cidr_block, var.subnet_public_az_b_cidr_block]
  }

  egress {
    description      = "Saida para qualquer IP em qualquer porta"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.all_ips_cidr_block]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "webservers"
  }
}

#Define a instância da máquina EC2
resource "aws_instance" "wordpress" {
  count                       = var.instance_count
  ami                         = var.ami_wordpress
  instance_type               = var.instance_type
  key_name                    = var.ssh_key
  monitoring                  = true
  vpc_security_group_ids      = [aws_security_group.webservers.id]
  subnet_id                   = aws_subnet.public_az_a.id
  associate_public_ip_address = true

  /* user_data = <<-EOF
    #!/bin/bash
    sudo apt update && sudo apt install curl ansible unzip -y

    # wget https://github.com/well/desafio-final-formacao-sre.zip
    # unzip desafio-final-formacao-sre.zip
    # cd desafio-final-formacao-sre/ansible/
    # ansible-playbook ...

    cd /tmp
    wget https://esseeutenhocertezaqueninguemcriou.s3.amazonaws.com/ansible.zip
    unzip ansible.zip

    sudo ansible-playbook wordpress.yml \
      --inventory 'localhost,' \
      --connection local \
      --extra-vars "wordpress_db_host=${aws_db_instance.this.address}" \
      --extra-vars "wordpress_db_name=${aws_db_instance.this.db_name}" \
      --extra-vars "wordpress_db_username=${aws_db_instance.this.username}" \
      --extra-vars "wordpress_db_password=${aws_db_instance.this.password}" \
      --extra-vars "wordpress_address=${aws_instance.wordpress.public_ip}"
  EOF */

  /* user_data                   = <<-EOF
              #!/bin/bash 
              sudo apt update && sudo apt install curl ansible unzip -y 
              cd /tmp
              wget https://esseeutenhocertezaqueninguemcriou.s3.amazonaws.com/ansible.zip
              unzip ansible.zip
              sudo ansible-playbook wordpress.yml
              EOF */


  /*   provisioner "remote-exec" {
    inline = ["echo 'Aguardando até o SSH estar disponivel'"]

    connection {
      type        = "ssh"
      user        = "local.ssh_user"
      private_key = file(local.private_key_path)
      host        = aws_instance.wordpress.public_ip
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook ./ansible/wordpress.yml -i ${aws_instance.wordpress.public_ip} --user ${local.ssh_user} --key-file ${local.private_key_path}"
  } */

  tags = {
    Name = "Wordpress"
  }

  depends_on = [
    aws_db_instance.this
  ]
}
