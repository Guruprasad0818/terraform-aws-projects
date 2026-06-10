# Project 1 — Terraform Remote State Management

## What I Built
A remote backend for Terraform using AWS S3 + DynamoDB state locking.

## Architecture
S3 Bucket (stores terraform.tfstate remotely)
- Versioning enabled
- Public access blocked
- Server-side encryption enabled

DynamoDB Table (terraform-state-lock)
- Prevents simultaneous apply operations

## Tech Stack
- Terraform v1.x
- AWS S3
- AWS DynamoDB

## How to Run
```bash
git clone [https://github.com/yourusername/terraform-aws-projects.git](https://github.com/yourusername/terraform-aws-projects.git)
cd terraform-aws-projects/01-remote-state-s3-dynamodb
terraform init
terraform plan
terraform apply