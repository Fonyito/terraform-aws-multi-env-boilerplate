# ==============================================================================
# Auto Scaling Group Module - Variables
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
  description = "IDs de las subnets privadas para las instancias EC2"
  type        = list(string)
}

variable "security_group_id" {
  description = "ID del security group para las instancias EC2"
  type        = string
}

variable "target_group_arn" {
  description = "ARN del target group del ALB"
  type        = string
}

variable "ami_id" {
  description = "ID de la AMI para las instancias EC2"
  type        = string
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t3.micro"
}

variable "iam_instance_profile_name" {
  description = "Nombre del IAM instance profile para las instancias EC2"
  type        = string
}

variable "min_size" {
  description = "Número mínimo de instancias en el ASG"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Número máximo de instancias en el ASG"
  type        = number
  default     = 6
}

variable "desired_capacity" {
  description = "Número deseado de instancias en el ASG"
  type        = number
  default     = 2
}

variable "enable_detailed_monitoring" {
  description = "Habilitar monitoreo detallado de CloudWatch"
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

# WordPress and EFS configuration
variable "efs_id" {
  description = "ID del sistema de archivos EFS"
  type        = string
}

variable "db_host" {
  description = "Endpoint de la base de datos RDS"
  type        = string
}

variable "db_name" {
  description = "Nombre de la base de datos"
  type        = string
}

variable "db_user" {
  description = "Usuario de la base de datos"
  type        = string
}

variable "db_password" {
  description = "Contraseña de la base de datos"
  type        = string
  sensitive   = true
}

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
  description = "Email del administrador de WordPress"
  type        = string
  default     = "admin@example.com"
}

variable "tags" {
  description = "Tags adicionales para los recursos"
  type        = map(string)
  default     = {}
}
