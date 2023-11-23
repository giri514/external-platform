resource "aws_s3_bucket" "data_storage" {
  bucket = "${var.s3_bucket_name}-${var.environment}"
  acl    = "private"

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket" "data_storage_mincron" {
  bucket = "${var.s3_bucket_name_mincron}-${var.environment}"
  acl    = "private"

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket" "data_storage_bk" {
  bucket = "${var.s3_bucket_name_bk}-${var.environment}"
  acl    = "private"
}

resource "aws_s3_bucket" "lambda_deps" {
  bucket = "${var.s3_bucket_name_lambda_deps}-${var.environment}"
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
