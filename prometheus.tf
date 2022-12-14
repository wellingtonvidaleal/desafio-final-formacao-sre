#Define o grupo de segurança do Prometheus
resource "aws_security_group" "prometheus" {
  name        = "prometheus"
  description = "Definicao de acessos do Prometheus"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "Conexoes do bastion host"
    from_port       = 0
    to_port         = 0
    protocol        = -1
    security_groups = [aws_security_group.bastion_host.id]
  }

  ingress {
    description = "Servico do Prometheus de fora para dentro"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Servico do grafana de fora para dentro"
    from_port   = 3000
    to_port     = 3000
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

  tags = merge(local.monitoring_tags,
    {
      Name = "${var.environment}-monitoring"
    }
  )
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

#Define o EC2 do Prometheus e Grafana
resource "aws_instance" "prometheus" {
  #AMI Ubuntu Server 22.04 LTS (HVM), SSD Volume Type
  ami                         = "ami-0574da719dca65348"
  instance_type               = var.instance_type
  key_name                    = var.ssh_key
  monitoring                  = true
  vpc_security_group_ids      = [aws_security_group.prometheus.id]
  subnet_id                   = aws_subnet.public_az_a.id
  associate_public_ip_address = true

  user_data = base64encode(local.user_data_prometheus)

  tags = merge(local.monitoring_tags,
    {
      Name = "${var.environment}-prometheus"
    }
  )
}

resource "aws_iam_group" "monitoring" {
  name = "monitoring"
  path = "/users/"
}

resource "aws_iam_user" "prometheus" {
  name = "prometheus"
  path = "/system/"

  tags = merge(local.monitoring_tags,
    {
      Name    = "${var.environment}-monitoring"
      tag-key = "tag-value"
    }
  )
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