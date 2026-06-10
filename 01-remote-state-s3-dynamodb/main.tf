# main.tf
# Defines the Terraform configuration and all AWS resources. [cite: 331]

# ─────────────────────────────────────────────────────────────
# BLOCK 1: Terraform configuration & Remote Backend Setup
# Tells Terraform to use your S3 bucket and DynamoDB table for state. [cite: 333, 334, 467]
# ─────────────────────────────────────────────────────────────
terraform {
  backend "s3" {
    bucket         = "terraform-state-guruprasad-2025"  # Your exact live S3 bucket name [cite: 472]
    key            = "01-remote-state/terraform.tfstate" # The path within the bucket where the state file is stored [cite: 473, 485]
    region         = "us-east-1"                         # Must match the region of your bucket [cite: 474, 485]
    dynamodb_table = "terraform-state-lock"             # Your DynamoDB table for distributed locking [cite: 475, 485]
    encrypt        = true                                # Encrypts the state file at rest and in transit [cite: 476, 485]
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"  # [cite: 339]
      version = "~> 5.0"         # Use any 5.x version [cite: 340]
    }
  }
}

# ─────────────────────────────────────────────────────────────
# BLOCK 2: AWS Provider configuration
# Tells Terraform which AWS region to use. [cite: 345, 346]
# ─────────────────────────────────────────────────────────────
provider "aws" {
  region = var.aws_region   # Defined in variables.tf or terraform.tfvars [cite: 347, 350]
}

# ─────────────────────────────────────────────────────────────
# BLOCK 3: S3 Bucket Resource Block
# This bucket stores the terraform.tfstate file remotely in the cloud. [cite: 114, 354]
# ─────────────────────────────────────────────────────────────
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.bucket_name   # Name comes from terraform.tfvars [cite: 357]

  lifecycle {
    prevent_destroy = true   # Prevents accidental deletion of the bucket [cite: 359]
  }

  tags = {
    Name        = "Terraform State Bucket" # [cite: 362]
    Environment = "Learning"              # [cite: 363]
    Project     = "01-remote-state"        # [cite: 364]
    ManagedBy   = "Terraform"              # [cite: 365]
  }
}

# Enable versioning so you can see and recover previous state files [cite: 82]
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id # [cite: 369]

  versioning_configuration {
    status = "Enabled" # [cite: 370, 371]
  }
}

# Block all public access to the state bucket to keep data private [cite: 82]
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id # [cite: 375]

  block_public_acls       = true # [cite: 376]
  block_public_policy     = true # [cite: 377]
  ignore_public_acls      = true # [cite: 378]
  restrict_public_buckets = true # [cite: 379]
}

# Encrypt the state file at rest using AES-256 (SSE-S3)
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id # [cite: 382]

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" # [cite: 385]
    }
  }
}

# ─────────────────────────────────────────────────────────────
# BLOCK 4: DynamoDB Table Resource Block
# DynamoDB table used for state locking and consistency checks. [cite: 82]
# ─────────────────────────────────────────────────────────────
resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.dynamodb_table_name # [cite: 390]
  billing_mode = "PAY_PER_REQUEST"       # [cite: 391]
  hash_key     = "LockID"                 # Must be exactly 'LockID' for Terraform backend [cite: 392]

  attribute {
    name = "LockID" # [cite: 394]
    type = "S"      # String type [cite: 395]
  }

  tags = {
    Name        = "Terraform State Lock Table" # [cite: 398]
    Environment = "Learning"                   # [cite: 399]
    ManagedBy   = "Terraform"                  # [cite: 400]
  }
}