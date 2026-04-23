# ==============================================================================
# WordPress HA Example - Outputs
# ==============================================================================

output "alb_dns_name" {
  description = "Nombre DNS del Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "alb_zone_id" {
  description = "Zone ID del ALB para configuración de Route53"
  value       = module.alb.alb_zone_id
}

output "vpc_id" {
  description = "ID de la VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs de las subnets públicas"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs de las subnets privadas"
  value       = module.vpc.private_subnet_ids
}

output "rds_endpoint" {
  description = "Endpoint de la base de datos RDS"
  value       = module.rds.db_instance_endpoint
  sensitive   = true
}

output "efs_id" {
  description = "ID del sistema de archivos EFS"
  value       = module.efs.efs_id
}

output "efs_dns_name" {
  description = "Nombre DNS del EFS"
  value       = module.efs.efs_dns_name
}

output "autoscaling_group_name" {
  description = "Nombre del Auto Scaling Group"
  value       = module.asg.autoscaling_group_name
}

output "wordpress_url" {
  description = "URL para acceder a WordPress"
  value       = "http://${module.alb.alb_dns_name}"
}
