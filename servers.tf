#Define as primeiras máquinas de teste
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  #for_each = toset(["Wordpress01", "Wordpress02"])
  for_each = toset(["Wordpress01"])

  name = "instance-${each.key}"

  ami                         = var.amiWordpress
  instance_type               = "t2.micro"
  key_name                    = var.chaveSSH
  monitoring                  = false
  vpc_security_group_ids      = [aws_security_group.ServidoresWeb.id]
  subnet_id                   = aws_subnet.Pub-AZ-A.id
  associate_public_ip_address = true

  tags = {
    Name        = "${each.key}"
    Environment = "test"
  }
}