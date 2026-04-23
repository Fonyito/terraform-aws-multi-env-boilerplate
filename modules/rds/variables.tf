# ==============================================================================
# RDS Module - Variables
# ==============================================================================

variable "project_name" {
  description = "Nombre del proyecto para nombrado de recursos"
  type        = string
}

variable "environment" {
  description = "Nombre del entorno (dev, staging, prod)"
  type        = string
}

variable "subnet_ids" {
  description = "IDs de las subnets privadas para el DB subnet group"
  type        = list(string)
}

variable "security_group_id" {
  description = "ID del security group para RDS"
  type        = string
}

variable "engine_version" {
  description = "Versión del motor MySQL"
  type        = string
  default     = "8.0"
}

variable "instance_class" {
  description = "Clase de instancia RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Almacenamiento asignado en GB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Almacenamiento máximo para autoscaling en GB"
  type        = number
  default     = 100
}

variable "database_name" {
  description = "Nombre de la base de datos inicial"
  type        = string
  default     = "wordpress"
}

variable "master_username" {
  description = "Usuario maestro de la base de datos"
  type        = string
  default     = "admin"
}

variable "master_password" {
  description = "Contraseña del usuario maestro (usar AWS Secrets Manager en producción)"
  type        = string
  sensitive   = true
}

variable "multi_az" {
  description = "Habilitar despliegue Multi-AZ para alta disponibilidad"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Días de retención de backups automáticos"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Ventana de tiempo para backups automáticos (UTC)"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Ventana de tiempo para mantenimiento (UTC)"
  type        = string
  default     = "mon:04:00-mon:05:00"
}

variable "skip_final_snapshot" {
  description = "Omitir snapshot final al destruir la base de datos"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags adicionales para los recursos"
  type        = map(string)
  default     = {}
}
