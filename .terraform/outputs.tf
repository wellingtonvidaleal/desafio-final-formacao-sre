output "wordpress_ip" {
  description = "IP publico do servidor wordpress"
  value       = try(aws_instance.wordpress.public_ip)
}