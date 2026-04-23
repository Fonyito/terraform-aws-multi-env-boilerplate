output "alb_security_group_id" {
  description = "ID del security group del ALB"
  value       = aws_security_group.alb.id
}

output "ec2_security_group_id" {
  description = "ID del security group de las instancias EC2"
  value       = aws_security_group.ec2.id
}

output "rds_security_group_id" {
  description = "ID del security group de RDS"
  value       = aws_security_group.rds.id
}

output "efs_security_group_id" {
  description = "ID del security group de EFS"
  value       = aws_security_group.efs.id
}
