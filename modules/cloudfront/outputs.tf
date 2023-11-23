output "cloudfront_domain_name" {
  description = "The URL of the static website hosted in the S3 Bucket"
  value       = aws_cloudfront_distribution.web_driver_distribution.domain_name
}

output "cloudfront_id" {
  value = aws_cloudfront_distribution.web_driver_distribution.id
}
