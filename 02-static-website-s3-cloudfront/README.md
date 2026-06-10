# Project 2 — Static Website S3 + CloudFront
 
## Live Demo
https://d2vu8oxch1coxg.cloudfront.net  <- replace with your actual URL
 
## What I Built
A static website hosted on AWS S3, delivered globally via CloudFront CDN.
Fully provisioned with Terraform — zero manual AWS console clicks.
 
## Architecture
- S3 Bucket (private) — stores HTML, CSS files
- CloudFront Distribution — CDN with 400+ global edge locations
- Origin Access Control — CloudFront-only S3 access (no public S3 URL)
- HTTPS enforced via CloudFront default certificate
 
## Tech Stack
Terraform v1.x + AWS S3 + AWS CloudFront
 
## How to Run
```bash
git clone https://github.com/Guruprasad0818/terraform-aws-projects
cd terraform-aws-projects/02-static-website-s3-cloudfront
# Update terraform.tfvars with your unique bucket name
terraform init
terraform plan
terraform apply
```
 
## What I Learned
- How CloudFront CDN improves performance and security vs direct S3 hosting
- Origin Access Control (OAC) to keep S3 private while serving via CloudFront
- Uploading files to S3 using aws_s3_object in Terraform
- Cache invalidation for website updates
