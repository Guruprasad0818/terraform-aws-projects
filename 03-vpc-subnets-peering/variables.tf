# variables.tf
 
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
 
variable "vpc_a_cidr" {
  description = "CIDR block for VPC A"
  type        = string
  default     = "10.0.0.0/16"
}
 
variable "vpc_b_cidr" {
  description = "CIDR block for VPC B"
  type        = string
  default     = "10.1.0.0/16"
}
 
variable "vpc_a_public_subnet_cidr" {
  description = "Public subnet CIDR in VPC A"
  type        = string
  default     = "10.0.1.0/24"
}
 
variable "vpc_a_private_subnet_cidr" {
  description = "Private subnet CIDR in VPC A"
  type        = string
  default     = "10.0.2.0/24"
}
 
variable "vpc_b_public_subnet_cidr" {
  description = "Public subnet CIDR in VPC B"
  type        = string
  default     = "10.1.1.0/24"
}
 
variable "vpc_b_private_subnet_cidr" {
  description = "Private subnet CIDR in VPC B"
  type        = string
  default     = "10.1.2.0/24"
}
