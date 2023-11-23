variable "aws_region" {
  type        = string
  description = "The region where the AWS Resources will be configured."
  default     = "us-east-1"
}

variable "lambda_function_post_name" {
  description = "The name of the lambda post processing data function."
  type        = string
  default     = "post-processor"
}

variable "step_function_name_post" {
  description = "The name of the step function."
  type        = string
  default     = "post-product-tagging-etl"
}

variable "environment" {
  type        = string
  description = "Execution environment"
}
  
