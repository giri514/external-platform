resource "aws_s3_bucket" "post-processing-etl" {
  bucket = "reece-post-product-processing-etl-${var.environment}"
  acl    = "private"

  versioning {
    enabled = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}