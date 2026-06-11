# Project 3 — VPC + Subnets + VPC Peering
 
## Architecture
(paste your AWS Console VPC screenshot here)
 
## What I Built
Two isolated VPCs (VPC A: 10.0.0.0/16, VPC B: 10.1.0.0/16) with public and
private subnets, internet gateways, route tables, and a VPC Peering connection
allowing private communication between both networks.
 
## Resources Created
- 2 VPCs with DNS hostnames enabled
- 4 Subnets (2 public, 2 private across both VPCs)
- 2 Internet Gateways
- 4 Route Tables with peering routes
- 1 VPC Peering Connection (Active)
 
## Tech Stack
Terraform v1.x + AWS VPC + AWS Networking
 
## How to Run
```bash
cd 03-vpc-subnets-peering
terraform init && terraform plan && terraform apply
```
 
## What I Learned
- CIDR block planning — why non-overlapping ranges are required for peering
- Difference between public and private subnets
- How route tables control traffic flow between subnets and VPCs
- VPC Peering for private inter-VPC communication
