output "wordpress_ip" {
  description = "IP publico do servidor wordpress"
  value       = try(aws_instance.wordpress.public_ip)
}

output "database_endpoint" {
  description = "IP publico do banco de dados MySQL"
  value       = try(aws_db_instance.BancoDeDadosWordpress.endpoint)
}