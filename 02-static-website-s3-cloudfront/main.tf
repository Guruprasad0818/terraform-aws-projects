# main.tf
 
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
 
provider "aws" {
  region = var.aws_region
}
 
# ─────────────────────────────────────────────────────────────
# BLOCK 1: S3 Bucket
# This bucket stores your website files.
# Note: force_destroy = true so we can delete it with terraform destroy
# (unlike Project 1 where we used prevent_destroy to protect state)
# ─────────────────────────────────────────────────────────────
resource "aws_s3_bucket" "website" {
  bucket        = var.bucket_name
  force_destroy = true
 
  tags = {
    Name      = var.project_name
    ManagedBy = "Terraform"
  }
}
 
# ─────────────────────────────────────────────────────────────
# BLOCK 2: Block all public access to S3
# The bucket is PRIVATE. Only CloudFront accesses it via OAC.
# ─────────────────────────────────────────────────────────────
resource "aws_s3_bucket_public_access_block" "website" {
  bucket                  = aws_s3_bucket.website.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
 
# ─────────────────────────────────────────────────────────────
# BLOCK 3: Origin Access Control
# Allows CloudFront to authenticate with S3.
# signing_behavior = always: always sign requests
# signing_protocol = sigv4: AWS Signature Version 4
# ─────────────────────────────────────────────────────────────
resource "aws_cloudfront_origin_access_control" "website" {
  name                              = "${var.project_name}-oac"
  description                       = "OAC for ${var.bucket_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
 
# ─────────────────────────────────────────────────────────────
# BLOCK 4: CloudFront Distribution
# This is the CDN. It delivers your website globally.
# ─────────────────────────────────────────────────────────────
resource "aws_cloudfront_distribution" "website" {
  enabled             = true
  default_root_object = "index.html"   # serve index.html for /
  comment             = var.project_name
 
  # Where CloudFront fetches files from (your S3 bucket)
  origin {
    domain_name              = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.website.id
    origin_access_control_id = aws_cloudfront_origin_access_control.website.id
  }
 
  # Default behavior: cache and forward all requests
  default_cache_behavior {
    target_origin_id       = aws_s3_bucket.website.id
    viewer_protocol_policy = "redirect-to-https"  # force HTTPS
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
 
    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }
 
    # How long CloudFront caches files (in seconds)
    min_ttl     = 0
    default_ttl = 3600    # 1 hour
    max_ttl     = 86400   # 24 hours
  }
 
  # Custom 404 handling: show your error.html instead of AWS XML error
  custom_error_response {
    error_code            = 403
    response_code         = 404
    response_page_path    = "/error.html"
    error_caching_min_ttl = 10
  }
 
  # Geographic restrictions (none = worldwide access)
  restrictions {
    geo_restriction { restriction_type = "none" }
  }
 
  # Use default CloudFront SSL certificate (for *.cloudfront.net domain)
  viewer_certificate {
    cloudfront_default_certificate = true
  }
 
  tags = {
    Name      = var.project_name
    ManagedBy = "Terraform"
  }
}
 
# ─────────────────────────────────────────────────────────────
# BLOCK 5: Bucket Policy — Allow CloudFront to read S3
# This policy grants GetObject permission ONLY to the specific
# CloudFront distribution (via OAC).
# depends_on ensures CloudFront exists before the policy is applied.
# ─────────────────────────────────────────────────────────────
data "aws_iam_policy_document" "cloudfront_oac_access" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.website.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.website.arn]
    }
  }
}
 
resource "aws_s3_bucket_policy" "website" {
  bucket     = aws_s3_bucket.website.id
  policy     = data.aws_iam_policy_document.cloudfront_oac_access.json
  depends_on = [aws_cloudfront_distribution.website]
}
 
# ─────────────────────────────────────────────────────────────
# BLOCK 6: Upload website files to S3
# aws_s3_object uploads each file individually.
# content_type tells CloudFront how to serve each file.
# ─────────────────────────────────────────────────────────────
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.website.id
  key          = "index.html"
  source       = "website/index.html"
  content_type = "text/html"
  etag         = filemd5("website/index.html")
}
 
resource "aws_s3_object" "error" {
  bucket       = aws_s3_bucket.website.id
  key          = "error.html"
  source       = "website/error.html"
  content_type = "text/html"
  etag         = filemd5("website/error.html")
}
 
resource "aws_s3_object" "styles" {
  bucket       = aws_s3_bucket.website.id
  key          = "styles.css"
  source       = "website/styles.css"
  content_type = "text/css"
  etag         = filemd5("website/styles.css")
}
