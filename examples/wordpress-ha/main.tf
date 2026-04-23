# ==============================================================================
# WordPress High Availability Example
# ==============================================================================
# Este ejemplo despliega una arquitectura de WordPress de alta disponibilidad
# utilizando los módulos reutilizables del proyecto
# ==============================================================================

terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }

  backend "s3" {
    bucket         = "tu-empresa-terraform-state"
    key            = "wordpress-ha/${terraform.workspace}/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Example     = "WordPress-HA"
    }
  }
}

# ==============================================================================
# Data Sources
# ==============================================================================

# Obtener la AMI más reciente de Amazon Linux 2023
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ==============================================================================
# VPC Module
# ==============================================================================

module "vpc" {
  source = "../../modules/vpc"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_nat_gateway   = var.enable_nat_gateway

  tags = var.tags
}

# ==============================================================================
# Security Groups Module
# ==============================================================================

module "security_groups" {
  source = "../../modules/security-groups"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id

  tags = var.tags
}

# ==============================================================================
# Application Load Balancer Module
# ==============================================================================

module "alb" {
  source = "../../modules/alb"

  project_name               = var.project_name
  environment                = var.environment
  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.public_subnet_ids
  security_group_id          = module.security_groups.alb_security_group_id
  enable_deletion_protection = var.enable_deletion_protection
  health_check_path          = "/"

  tags = var.tags
}

# ==============================================================================
# RDS Module
# ==============================================================================

module "rds" {
  source = "../../modules/rds"

  project_name            = var.project_name
  environment             = var.environment
  subnet_ids              = module.vpc.private_subnet_ids
  security_group_id       = module.security_groups.rds_security_group_id
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  max_allocated_storage   = var.db_max_allocated_storage
  database_name           = var.db_name
  master_username         = var.db_username
  master_password         = var.db_password
  multi_az                = var.db_multi_az
  backup_retention_period = var.db_backup_retention_period
  skip_final_snapshot     = var.db_skip_final_snapshot

  tags = var.tags
}

# ==============================================================================
# EFS Module
# ==============================================================================

module "efs" {
  source = "../../modules/efs"

  project_name      = var.project_name
  environment       = var.environment
  subnet_ids        = module.vpc.private_subnet_ids
  security_group_id = module.security_groups.efs_security_group_id
  performance_mode  = var.efs_performance_mode
  throughput_mode   = var.efs_throughput_mode
  transition_to_ia  = var.efs_transition_to_ia
  enable_backup     = var.efs_enable_backup

  tags = var.tags
}

# ==============================================================================
# IAM Role for EC2 Instances
# ==============================================================================

resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-${var.environment}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-${var.environment}-ec2-profile"
  role = aws_iam_role.ec2_role.name

  tags = var.tags
}

# ==============================================================================
# Auto Scaling Group Module
# ==============================================================================

module "asg" {
  source = "../../modules/asg"

  project_name              = var.project_name
  environment               = var.environment
  subnet_ids                = module.vpc.private_subnet_ids
  security_group_id         = module.security_groups.ec2_security_group_id
  target_group_arn          = module.alb.target_group_arn
  ami_id                    = data.aws_ami.amazon_linux_2023.id
  instance_type             = var.instance_type
  iam_instance_profile_name = aws_iam_instance_profile.ec2_profile.name
  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  desired_capacity          = var.asg_desired_capacity
  enable_detailed_monitoring = var.enable_detailed_monitoring
  scale_up_cpu_threshold    = var.scale_up_cpu_threshold
  scale_down_cpu_threshold  = var.scale_down_cpu_threshold

  # WordPress configuration
  efs_id          = module.efs.efs_id
  db_host         = module.rds.db_instance_address
  db_name         = var.db_name
  db_user         = var.db_username
  db_password     = var.db_password
  wordpress_title = var.wordpress_title
  wordpress_admin = var.wordpress_admin
  wordpress_email = var.wordpress_email

  tags = var.tags
}
