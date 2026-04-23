variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "environment" {
  description = "Nombre del entorno"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC"
  type        = string
}

variable "subnet_ids" {
  description = "IDs de las subnets para el ALB"
  type        = list(string)
}

variable "security_group_id" {
  description = "ID del security group del ALB"
  type        = string
}

variable "health_check_path" {
  description = "Ruta para health check"
  type        = string
  default     = "/"
}

variable "enable_deletion_protection" {
  description = "Habilitar protección contra eliminación"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags adicionales"
  type        = map(string)
  default     = {}
}
