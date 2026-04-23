# ==============================================================================
# Main Infrastructure Configuration
# ==============================================================================
# This file contains the main infrastructure resources and module calls.
# It demonstrates:
# - Resource creation with environment-specific naming
# - Variable usage for dynamic configuration
# - Module references from the modules/ directory
# - Best practices for resource organization
#
# Usage:
#   terraform workspace select <environment>
#   terraform plan -var-file=environments/<environment>.tfvars
#   terraform apply -var-file=environments/<environment>.tfvars
# ==============================================================================

# ------------------------------------------------------------------------------
# Example S3 Bucket Resource
# ------------------------------------------------------------------------------
# This S3 bucket demonstrates:
# - Environment-specific naming using variables
# - Resource creation with Terraform
# - Automatic tagging via provider default_tags
#
# The bucket name follows the pattern: <project_name>-<environment>-example
# Example: terraform-aws-boilerplate-dev-example
# ------------------------------------------------------------------------------

resource "aws_s3_bucket" "example" {
  bucket = "${var.project_name}-${var.environment}-example"

  # Tags are automatically applied via provider default_tags configuration
  # Additional tags can be added here if needed
  tags = {
    Description = "Example S3 bucket demonstrating resource creation"
    Purpose     = "Boilerplate demonstration"
  }
}

# ------------------------------------------------------------------------------
# Example Module Call
# ------------------------------------------------------------------------------
# This demonstrates how to reference modules from the modules/ directory.
# Modules allow you to create reusable infrastructure components.
#
# To create a module:
# 1. Create a directory under modules/ (e.g., modules/s3-bucket/)
# 2. Add main.tf, variables.tf, and outputs.tf to the module directory
# 3. Reference the module here using the source parameter
#
# Example module structure:
#   modules/
#   └── s3-bucket/
#       ├── main.tf       # Module resources
#       ├── variables.tf  # Module input variables
#       └── outputs.tf    # Module outputs
#
# Uncomment the block below once you create your first module:
# ------------------------------------------------------------------------------

# module "example_module" {
#   source = "./modules/example"
#   
#   # Pass variables to the module
#   environment  = var.environment
#   project_name = var.project_name
#   aws_region   = var.aws_region
#   
#   # Module-specific variables
#   # Add any additional variables required by your module
# }

# ------------------------------------------------------------------------------
# Best Practices and Guidelines
# ------------------------------------------------------------------------------
# 1. Resource Naming: Use consistent naming patterns with environment prefixes
#    Example: ${var.project_name}-${var.environment}-<resource-type>
#
# 2. Tagging: Leverage provider default_tags for consistent tagging
#    Add resource-specific tags only when needed
#
# 3. Module Organization: Group related resources into modules
#    Keep main.tf focused on high-level infrastructure composition
#
# 4. Variable Usage: Reference variables for all environment-specific values
#    Avoid hardcoding values that differ between environments
#
# 5. Comments: Document complex resources and explain design decisions
#    Help future maintainers understand the infrastructure
#
# 6. Resource Dependencies: Use implicit dependencies (resource references)
#    Use explicit depends_on only when necessary
#
# 7. State Management: Resources defined here are stored in workspace-specific
#    state files in S3: terraform/<workspace>/terraform.tfstate
# ------------------------------------------------------------------------------
