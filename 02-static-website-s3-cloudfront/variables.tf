# variables.tf
 
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
 
variable "bucket_name" {
  description = "Unique S3 bucket name for the website"
  type        = string
}
 
variable "project_name" {
  description = "Tag prefix for all resources"
  type        = string
  default     = "static-website"
}
