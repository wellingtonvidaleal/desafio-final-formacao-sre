output "aws_db_instance_this_address" {
  description = "IP publico do banco de dados MySQL"
  value       = try(aws_db_instance.this.address)
}

/* output "aws_db_instance_this_db_name" {
  description = "Nome do banco de dados"
  value       = try(aws_db_instance.this.db_name)
}

output "aws_db_instance_this_username" {
  description = "Nome do usuario do banco de dadosL"
  value       = try(aws_db_instance.this.username)
} */