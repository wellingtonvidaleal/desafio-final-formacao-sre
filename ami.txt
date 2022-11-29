resource "aws_ami_from_instance" "this" {
  name               = "ami_wordpress_wellington_vida_leal"
  source_instance_id = aws_instance.wordpress.id
  depends_on = [
    aws_instance.wordpress
  ]
}