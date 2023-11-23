resource "aws_s3_bucket" "deployment_bucket" {
  count  = var.environment == "dev" ? 1 : 0
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Environment = var.environment
  }
}



resource "aws_s3_bucket" "max_delivery_proof_bucket" {
  bucket = "${var.max_delivery_proof_bucket_name}-${var.environment}"

  tags = {
    Name        = var.max_delivery_proof_bucket_name
    Environment = var.environment
  }
}

resource "aws_s3_bucket" "reece_external_product_img_store" {
  bucket = "reece-external-product-img-store-${var.environment}"

  tags = {
    Name        = "reece-external-product-img-store-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "reece_external_product_img_store" {
  bucket = aws_s3_bucket.reece_external_product_img_store.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_cors_configuration" "reece_external_product_img_store" {
  bucket = aws_s3_bucket.reece_external_product_img_store.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_acl" "reece_external_product_img_store" {
  bucket     = aws_s3_bucket.reece_external_product_img_store.id
  acl        = "public-read"
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.reece_external_product_img_store.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [aws_s3_bucket_public_access_block.reece_external_product_img_store]
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.reece_external_product_img_store.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Principal = "*"
        Action = [
          "s3:GetObject",
        ]
        Effect = "Allow"
        Resource  = [
          "arn:aws:s3:::${aws_s3_bucket.reece_external_product_img_store.id}",
          "arn:aws:s3:::${aws_s3_bucket.reece_external_product_img_store.id}/*"
        ]
      },
    ]
  })
}


resource "aws_s3_object" "folder_eclipse_deliverydetails" {
  bucket = aws_s3_bucket.max_delivery_proof_bucket.bucket
  key    = "ECLIPSE/DELIVERYDETAILS/"
}

resource "aws_s3_object" "folder_eclipse_images" {
  bucket = aws_s3_bucket.max_delivery_proof_bucket.bucket
  key    = "ECLIPSE/IMAGES/"
}

resource "aws_s3_object" "folder_mincron_deliverydetails" {
  bucket = aws_s3_bucket.max_delivery_proof_bucket.bucket
  key    = "MINCRON/DELIVERYDETAILS/"
}

resource "aws_s3_object" "folder_mincron_images" {
  bucket = aws_s3_bucket.max_delivery_proof_bucket.bucket
  key    = "MINCRON/IMAGES/"
}
