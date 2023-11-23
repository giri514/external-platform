output "s3_bucket_name" {
  value = var.environment == "dev" ? aws_s3_bucket.deployment_bucket[0].bucket : ""
  description = "The name of the deployment S3 bucket, if it is created."
}