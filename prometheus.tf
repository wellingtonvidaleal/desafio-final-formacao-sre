#Define o grupo de segurança
resource "aws_security_group" "prometheus" {
  name        = "prometheus"
  description = "Definicao de acessos do bastion host"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "Conexoes do bastion host"
    from_port       = 0
    to_port         = 0
    protocol        = -1
    security_groups = [aws_security_group.bastion_host.id]
  }

  ingress {
    description = "Libera entrada de tudo"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

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
    Name = "prometheus"
  }
}

#Define o EC2 do Prometheus
resource "aws_instance" "prometheus" {
  ami                         = var.ami_wordpress
  instance_type               = var.instance_type
  key_name                    = var.ssh_key
  monitoring                  = true
  vpc_security_group_ids      = [aws_security_group.prometheus.id]
  subnet_id                   = aws_subnet.public_az_a.id
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    sudo apt update && sudo apt install git curl ansible unzip -y
    cd /tmp
    git clone https://github.com/wellingtonvidaleal/ansible-desafio-final-formacao-sre.git
    cd ansible-desafio-final-formacao-sre

    sudo ansible-playbook prometheus.yml \
      --inventory 'localhost,' \
      --connection local
  EOF

  # user_data = <<-EOF
  #   #!/bin/bash
  #   sudo apt-get update
  #   sudo apt-get install \
  #   ca-certificates \
  #   curl \
  #   gnupg \
  #   lsb-release
  #   sudo mkdir -p /etc/apt/keyrings
  #   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  #   echo \
  #   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  #   $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  #   sudo apt-get update
  #   sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

  #   docker run -p 9090:9090 prom/prometheus

  # EOF  

  # user_data = <<-EOF
  #   #!/bin/bash
  #   sudo apt update && sudo apt install curl -y
  #   cd ~/
  #   wget https://github.com/prometheus/prometheus/releases/download/v2.40.5/prometheus-2.40.5.linux-amd64.tar.gz
  #   tar xvfz prometheus-*.tar.gz
  #   cd prometheus-2.40.5.linux-amd64
  #   ./prometheus --config.file=prometheus.yml
  # EOF

  tags = {
    Name = "prometheus"
  }
}