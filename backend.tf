# Backend Configuration for Remote State Management
# This configuration stores Terraform state files in S3 with DynamoDB locking
# for team collaboration and state consistency across environments.

terraform {
  backend "s3" {
    # S3 bucket name for storing state files
    # Note: This bucket must be created before running terraform init
    bucket = "your-terraform-state-bucket"

    # Workspace-aware state file path
    # Each workspace (dev/staging/prod) will have its own state file
    # Example paths:
    #   - terraform/dev/terraform.tfstate
    #   - terraform/staging/terraform.tfstate
    #   - terraform/prod/terraform.tfstate
    key = "terraform/${terraform.workspace}/terraform.tfstate"

    # AWS region where the S3 bucket is located
    region = "us-east-1"

    # DynamoDB table for state locking
    # Note: This table must be created before running terraform init
    # The table must have a primary key named "LockID" (String type)
    dynamodb_table = "terraform-state-lock"

    # Enable server-side encryption for state files
    # This ensures state files are encrypted at rest in S3
    encrypt = true
  }
}
