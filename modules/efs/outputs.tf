# ==============================================================================
# EFS Module - Outputs
# ==============================================================================

output "efs_id" {
  description = "ID del sistema de archivos EFS"
  value       = aws_efs_file_system.main.id
}

output "efs_arn" {
  description = "ARN del sistema de archivos EFS"
  value       = aws_efs_file_system.main.arn
}

output "efs_dns_name" {
  description = "Nombre DNS del sistema de archivos EFS"
  value       = aws_efs_file_system.main.dns_name
}

output "mount_target_ids" {
  description = "IDs de los mount targets"
  value       = aws_efs_mount_target.main[*].id
}

output "mount_target_dns_names" {
  description = "Nombres DNS de los mount targets"
  value       = aws_efs_mount_target.main[*].dns_name
}
