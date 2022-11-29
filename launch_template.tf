resource "aws_launch_template" "this" {
  name_prefix            = "terraform-"
  image_id               = aws_ami_from_instance.this.id
  instance_type          = var.instance_type
  key_name               = var.ssh_key
  vpc_security_group_ids = [aws_security_group.webservers.id]

  depends_on = [
    aws_instance.wordpress
  ]
}