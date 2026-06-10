# outputs.tf

output "s3_bucket_name" {
  description = "The name of the S3 bucket storing Terraform state"
  value       = aws_s3_bucket.terraform_state.id
}

output "s3_bucket_arn" {
  description = "The ARN (Amazon Resource Name) of the S3 bucket"
  value       = aws_s3_bucket.terraform_state.arn
}

output "s3_bucket_region" {
  description = "The AWS region where the S3 bucket is located"
  value       = aws_s3_bucket.terraform_state.region
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB state locking table"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "dynamodb_table_arn" {
  description = "The ARN of the DynamoDB table"
  value       = aws_dynamodb_table.terraform_locks.arn
}