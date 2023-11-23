variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "max_delivery_proof_bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
  default     = "max-delivery-proof"
}

variable "prevent_destroy" {
  description = "Prevents the bucket from being destroyed"
  type        = bool
  default     = false
}

variable "environment" {
  description = "The environment this bucket belongs to (e.g. prod, dev)"
  type        = string
  default     = "dev"
}
