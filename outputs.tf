output "database_endpoint" {
  description = "IP publico do banco de dados MySQL"
  value       = try(aws_db_instance.this.address)
}