# ==============================================================================
# RDS Module - Outputs
# ==============================================================================

output "db_instance_id" {
  description = "ID de la instancia RDS"
  value       = aws_db_instance.main.id
}

output "db_instance_arn" {
  description = "ARN de la instancia RDS"
  value       = aws_db_instance.main.arn
}

output "db_instance_endpoint" {
  description = "Endpoint de conexión de la base de datos"
  value       = aws_db_instance.main.endpoint
}

output "db_instance_address" {
  description = "Dirección del host de la base de datos"
  value       = aws_db_instance.main.address
}

output "db_instance_port" {
  description = "Puerto de la base de datos"
  value       = aws_db_instance.main.port
}

output "db_name" {
  description = "Nombre de la base de datos"
  value       = aws_db_instance.main.db_name
}

output "db_subnet_group_id" {
  description = "ID del DB subnet group"
  value       = aws_db_subnet_group.main.id
}
