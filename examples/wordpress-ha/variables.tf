# ==============================================================================
# WordPress HA Example - Variables
# ==============================================================================

# General Configuration
variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "wordpress-ha"
}

variable "environment" {
  description = "Nombre del entorno (dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Tags adicionales para todos los recursos"
  type        = map(string)
  default     = {}
}

# VPC Configuration
variable "vpc_cidr" {
  description = "Bloque CIDR para la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Zonas de disponibilidad"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "Bloques CIDR para subnets públicas"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Bloques CIDR para subnets privadas"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "enable_nat_gateway" {
  description = "Habilitar NAT Gateway para subnets privadas"
  type        = bool
  default     = true
}

# ALB Configuration
variable "enable_deletion_protection" {
  description = "Habilitar protección contra eliminación del ALB"
  type        = bool
  default     = false
}

# RDS Configuration
variable "db_engine_version" {
  description = "Versión del motor MySQL"
  type        = string
  default     = "8.0"
}

variable "db_instance_class" {
  description = "Clase de instancia RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Almacenamiento asignado en GB"
  type        = number
  default     = 20
}

variable "db_max_allocated_storage" {
  description = "Almacenamiento máximo para autoscaling en GB"
  type        = number
  default     = 100
}

variable "db_name" {
  description = "Nombre de la base de datos"
  type        = string
  default     = "wordpress"
}

variable "db_username" {
  description = "Usuario maestro de la base de datos"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Contraseña del usuario maestro"
  type        = string
  sensitive   = true
}

variable "db_multi_az" {
  description = "Habilitar despliegue Multi-AZ"
  type        = bool
  default     = false
}

variable "db_backup_retention_period" {
  description = "Días de retención de backups"
  type        = number
  default     = 7
}

variable "db_skip_final_snapshot" {
  description = "Omitir snapshot final al destruir"
  type        = bool
  default     = true
}

# EFS Configuration
variable "efs_performance_mode" {
  description = "Modo de rendimiento del EFS"
  type        = string
  default     = "generalPurpose"
}

variable "efs_throughput_mode" {
  description = "Modo de throughput del EFS"
  type        = string
  default     = "bursting"
}

variable "efs_transition_to_ia" {
  description = "Días hasta transición a Infrequent Access"
  type        = string
  default     = "AFTER_30_DAYS"
}

variable "efs_enable_backup" {
  description = "Habilitar backups automáticos de EFS"
  type        = bool
  default     = true
}

# EC2 and Auto Scaling Configuration
variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t3.micro"
}

variable "asg_min_size" {
  description = "Número mínimo de instancias"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Número máximo de instancias"
  type        = number
  default     = 6
}

variable "asg_desired_capacity" {
  description = "Número deseado de instancias"
  type        = number
  default     = 2
}

variable "enable_detailed_monitoring" {
  description = "Habilitar monitoreo detallado"
  type        = bool
  default     = false
}

variable "scale_up_cpu_threshold" {
  description = "Umbral de CPU para escalar hacia arriba (%)"
  type        = number
  default     = 70
}

variable "scale_down_cpu_threshold" {
  description = "Umbral de CPU para escalar hacia abajo (%)"
  type        = number
  default     = 30
}

# WordPress Configuration
variable "wordpress_title" {
  description = "Título del sitio WordPress"
  type        = string
  default     = "My WordPress Site"
}

variable "wordpress_admin" {
  description = "Usuario administrador de WordPress"
  type        = string
  default     = "admin"
}

variable "wordpress_email" {
  description = "Email del administrador"
  type        = string
  default     = "admin@example.com"
}
