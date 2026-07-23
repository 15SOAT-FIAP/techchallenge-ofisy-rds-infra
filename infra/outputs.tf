########################################
# OUTPUTS
########################################

output "rds_endpoint" {
  description = "Endpoint de conexão da instância RDS PostgreSQL"
  value       = aws_db_instance.main.endpoint
}

output "rds_address" {
  description = "Hostname/Endereço da instância RDS PostgreSQL"
  value       = aws_db_instance.main.address
}

output "rds_port" {
  description = "Porta do banco de dados RDS PostgreSQL"
  value       = aws_db_instance.main.port
}

output "rds_database_name" {
  description = "Nome do banco de dados PostgreSQL"
  value       = aws_db_instance.main.db_name
}

output "rds_username" {
  description = "Usuário administrativo do banco de dados"
  value       = aws_db_instance.main.username
  sensitive   = true
}

output "rds_security_group_id" {
  description = "ID do Security Group do RDS"
  value       = aws_security_group.rds.id
}
