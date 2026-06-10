# outputs.tf
 
output "cloudfront_url" {
  description = "Your live website URL — share this on LinkedIn!"
  value       = "https://${aws_cloudfront_distribution.website.domain_name}"
}
 
output "cloudfront_distribution_id" {
  description = "CloudFront Distribution ID (needed to invalidate cache)"
  value       = aws_cloudfront_distribution.website.id
}
 
output "s3_bucket_name" {
  description = "The S3 bucket storing website files"
  value       = aws_s3_bucket.website.id
}
