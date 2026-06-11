# main.tf
 
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
 
#   backend "s3" {
#     bucket         = "terraform-state-guruprasad-2025"
#     key            = "03-vpc-peering/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "terraform-state-lock"
#     encrypt        = true
#   }
}
 
provider "aws" {
  region = var.aws_region
}
 
# ─────────────────────────────────────────────────────────────
# VPC A
# ─────────────────────────────────────────────────────────────
resource "aws_vpc" "vpc_a" {
  cidr_block           = var.vpc_a_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
 
  tags = {
    Name      = "vpc-a"
    ManagedBy = "Terraform"
  }
}
 
# ─────────────────────────────────────────────────────────────
# VPC B
# ─────────────────────────────────────────────────────────────
resource "aws_vpc" "vpc_b" {
  cidr_block           = var.vpc_b_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
 
  tags = {
    Name      = "vpc-b"
    ManagedBy = "Terraform"
  }
}
 
# ─────────────────────────────────────────────────────────────
# INTERNET GATEWAYS
# An IGW allows resources in public subnets to reach the internet.
# Each VPC needs its own IGW.
# ─────────────────────────────────────────────────────────────
resource "aws_internet_gateway" "igw_a" {
  vpc_id = aws_vpc.vpc_a.id
  tags   = { Name = "igw-vpc-a" }
}
 
resource "aws_internet_gateway" "igw_b" {
  vpc_id = aws_vpc.vpc_b.id
  tags   = { Name = "igw-vpc-b" }
}
 
# ─────────────────────────────────────────────────────────────
# SUBNETS — VPC A
# ─────────────────────────────────────────────────────────────
resource "aws_subnet" "vpc_a_public" {
  vpc_id                  = aws_vpc.vpc_a.id
  cidr_block              = var.vpc_a_public_subnet_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true   # EC2s here get public IPs
  tags = { Name = "vpc-a-public-subnet" }
}
 
resource "aws_subnet" "vpc_a_private" {
  vpc_id                  = aws_vpc.vpc_a.id
  cidr_block              = var.vpc_a_private_subnet_cidr
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = false  # No public IPs
  tags = { Name = "vpc-a-private-subnet" }
}
 
# ─────────────────────────────────────────────────────────────
# SUBNETS — VPC B
# ─────────────────────────────────────────────────────────────
resource "aws_subnet" "vpc_b_public" {
  vpc_id                  = aws_vpc.vpc_b.id
  cidr_block              = var.vpc_b_public_subnet_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
  tags = { Name = "vpc-b-public-subnet" }
}
 
resource "aws_subnet" "vpc_b_private" {
  vpc_id                  = aws_vpc.vpc_b.id
  cidr_block              = var.vpc_b_private_subnet_cidr
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = false
  tags = { Name = "vpc-b-private-subnet" }
}
 
# ─────────────────────────────────────────────────────────────
# ROUTE TABLES — VPC A
# A route table is a set of rules (routes) that determine where
# network traffic from your subnet is directed.
# ─────────────────────────────────────────────────────────────
resource "aws_route_table" "vpc_a_public" {
  vpc_id = aws_vpc.vpc_a.id
 
  # Route all internet-bound traffic (0.0.0.0/0) to the IGW
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_a.id
  }
 
  # Route traffic destined for VPC B through the peering connection
  route {
    cidr_block                = var.vpc_b_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc_a_to_b.id
  }
 
  tags = { Name = "vpc-a-public-rt" }
}
 
resource "aws_route_table" "vpc_a_private" {
  vpc_id = aws_vpc.vpc_a.id
 
  # Route traffic to VPC B through peering (private subnet can also peer)
  route {
    cidr_block                = var.vpc_b_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc_a_to_b.id
  }
 
  tags = { Name = "vpc-a-private-rt" }
}
 
# ─────────────────────────────────────────────────────────────
# ROUTE TABLES — VPC B
# ─────────────────────────────────────────────────────────────
resource "aws_route_table" "vpc_b_public" {
  vpc_id = aws_vpc.vpc_b.id
 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_b.id
  }
 
  route {
    cidr_block                = var.vpc_a_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc_a_to_b.id
  }
 
  tags = { Name = "vpc-b-public-rt" }
}
 
resource "aws_route_table" "vpc_b_private" {
  vpc_id = aws_vpc.vpc_b.id
 
  route {
    cidr_block                = var.vpc_a_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc_a_to_b.id
  }
 
  tags = { Name = "vpc-b-private-rt" }
}
 
# ─────────────────────────────────────────────────────────────
# ROUTE TABLE ASSOCIATIONS
# Connect each subnet to its route table.
# Without this, subnets use the default VPC route table.
# ─────────────────────────────────────────────────────────────
resource "aws_route_table_association" "vpc_a_public" {
  subnet_id      = aws_subnet.vpc_a_public.id
  route_table_id = aws_route_table.vpc_a_public.id
}
 
resource "aws_route_table_association" "vpc_a_private" {
  subnet_id      = aws_subnet.vpc_a_private.id
  route_table_id = aws_route_table.vpc_a_private.id
}
 
resource "aws_route_table_association" "vpc_b_public" {
  subnet_id      = aws_subnet.vpc_b_public.id
  route_table_id = aws_route_table.vpc_b_public.id
}
 
resource "aws_route_table_association" "vpc_b_private" {
  subnet_id      = aws_subnet.vpc_b_private.id
  route_table_id = aws_route_table.vpc_b_private.id
}
 
# ─────────────────────────────────────────────────────────────
# VPC PEERING CONNECTION
# Requests a peering connection from VPC A to VPC B.
# auto_accept = true works when both VPCs are in the same account.
# ─────────────────────────────────────────────────────────────
resource "aws_vpc_peering_connection" "vpc_a_to_b" {
  vpc_id      = aws_vpc.vpc_a.id   # requester
  peer_vpc_id = aws_vpc.vpc_b.id   # accepter
  auto_accept = true               # same AWS account
 
  tags = {
    Name      = "vpc-a-to-vpc-b-peering"
    ManagedBy = "Terraform"
  }
}
