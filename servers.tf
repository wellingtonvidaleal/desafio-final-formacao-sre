locals {
  ssh_user         = "ubuntu"
  key_name         = "devops"
  private_key_path = "./devops.pem"
}

#Define a instância da máquina EC2
resource "aws_instance" "wordpress" {
  ami                         = var.amiWordpress
  instance_type               = var.instanceTypeWordpress
  key_name                    = local.key_name
  monitoring                  = true
  vpc_security_group_ids      = [aws_security_group.ServidoresWeb.id]
  subnet_id                   = aws_subnet.Pub_AZ_A.id
  associate_public_ip_address = true
  /* user_data                   = <<-EOF
              #!/bin/bash 
              sudo apt update && sudo apt install curl ansible unzip -y 
              cd /tmp
              wget https://esseeutenhocertezaqueninguemcriou.s3.amazonaws.com/ansible.zip
              unzip ansible.zip
              sudo ansible-playbook wordpress.yml
              EOF */


  provisioner "remote-exec" {
    inline = ["echo 'Aguardando até o SSH estar disponivel'"]

    connection {
      type        = "ssh"
      user        = "~/Downloads/devops.pem"
      private_key = file(local.private_key_path)
      host        = aws_instance.wordpress.public_ip
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook ./ansible/wordpress.yml -i ${aws_instance.wordpress.public_ip} --user ${local.ssh_user} --key-file ${local.private_key_path}"
  }

  tags = {
    Name = "Wordpress"
  }
}