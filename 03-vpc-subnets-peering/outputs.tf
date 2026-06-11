# outputs.tf
 
output "vpc_a_id" {
  description = "VPC A ID"
  value       = aws_vpc.vpc_a.id
}
 
output "vpc_b_id" {
  description = "VPC B ID"
  value       = aws_vpc.vpc_b.id
}
 
output "vpc_a_public_subnet_id" {
  description = "VPC A public subnet ID"
  value       = aws_subnet.vpc_a_public.id
}
 
output "vpc_a_private_subnet_id" {
  description = "VPC A private subnet ID"
  value       = aws_subnet.vpc_a_private.id
}
 
output "vpc_b_public_subnet_id" {
  description = "VPC B public subnet ID"
  value       = aws_subnet.vpc_b_public.id
}
 
output "vpc_b_private_subnet_id" {
  description = "VPC B private subnet ID"
  value       = aws_subnet.vpc_b_private.id
}
 
output "peering_connection_id" {
  description = "VPC Peering Connection ID"
  value       = aws_vpc_peering_connection.vpc_a_to_b.id
}

