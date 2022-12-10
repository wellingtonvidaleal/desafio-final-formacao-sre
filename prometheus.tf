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

locals {
  user_data_prometheus = templatefile(
    "${path.module}/templates/user_data_prometheus.tftpl",
    {
      prometheus_iam_access_key = aws_iam_access_key.prometheus.id
      prometheus_iam_secret_key = aws_iam_access_key.prometheus.secret
    }
  )
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

  user_data = base64encode(local.user_data_prometheus)

  tags = {
    Name = "prometheus"
  }
}

resource "aws_iam_group" "monitoring" {
  name = "monitoring"
  path = "/users/"
}

resource "aws_iam_user" "prometheus" {
  name = "prometheus"
  path = "/system/"

  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_access_key" "prometheus" {
  user = aws_iam_user.prometheus.name
}

resource "aws_iam_user_policy" "prometheus_ro" {
  name = "prometheus_ro"
  user = aws_iam_user.prometheus.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "ec2:Describe*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "elasticloadbalancing:Describe*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:ListMetrics",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:Describe*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "autoscaling:Describe*",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_group_membership" "monitorin_prometheus" {
  name = "monitorin_prometheus"

  users = [
    aws_iam_user.prometheus.name,
  ]

  group = aws_iam_group.monitoring.name
}

output "prometheus_access_key" {
  value = aws_iam_access_key.prometheus.id
}

output "prometheus_secret_key" {
  value     = aws_iam_access_key.prometheus.secret
  sensitive = true
}