# ==============================================================================
# EFS Module - Elastic File System
# ==============================================================================
# Creates an EFS file system with mount targets in multiple availability zones
# Used for shared storage across EC2 instances (WordPress uploads, plugins, themes)
# ==============================================================================

resource "aws_efs_file_system" "main" {
  creation_token = "${var.project_name}-${var.environment}-efs"
  encrypted      = true

  performance_mode = var.performance_mode
  throughput_mode  = var.throughput_mode

  lifecycle_policy {
    transition_to_ia = var.transition_to_ia
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-efs"
    }
  )
}

resource "aws_efs_mount_target" "main" {
  count           = length(var.subnet_ids)
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = var.subnet_ids[count.index]
  security_groups = [var.security_group_id]
}

resource "aws_efs_backup_policy" "main" {
  file_system_id = aws_efs_file_system.main.id

  backup_policy {
    status = var.enable_backup ? "ENABLED" : "DISABLED"
  }
}
