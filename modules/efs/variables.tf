# ==============================================================================
# EFS Module - Variables
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
  description = "IDs de las subnets privadas para mount targets"
  type        = list(string)
}

variable "security_group_id" {
  description = "ID del security group para EFS"
  type        = string
}

variable "performance_mode" {
  description = "Modo de rendimiento del EFS (generalPurpose o maxIO)"
  type        = string
  default     = "generalPurpose"

  validation {
    condition     = contains(["generalPurpose", "maxIO"], var.performance_mode)
    error_message = "El modo de rendimiento debe ser generalPurpose o maxIO."
  }
}

variable "throughput_mode" {
  description = "Modo de throughput (bursting o provisioned)"
  type        = string
  default     = "bursting"

  validation {
    condition     = contains(["bursting", "provisioned"], var.throughput_mode)
    error_message = "El modo de throughput debe ser bursting o provisioned."
  }
}

variable "transition_to_ia" {
  description = "Días hasta transición a Infrequent Access (AFTER_7_DAYS, AFTER_14_DAYS, AFTER_30_DAYS, AFTER_60_DAYS, AFTER_90_DAYS)"
  type        = string
  default     = "AFTER_30_DAYS"
}

variable "enable_backup" {
  description = "Habilitar backups automáticos de EFS"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags adicionales para los recursos"
  type        = map(string)
  default     = {}
}
