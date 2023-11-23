variable "step_function_arn" {
  type = string
  description = "ARN of the step function to be triggered"
}

variable "step_function_arn_mincron" {
  type = string
  description = "ARN of the step function to be triggered for mincron data"
}

variable "step_function_arn_bk" {
  type = string
  description = "ARN of the step function to be triggered for mincron data"
}

variable "branches_lambda_arn" {
  type = string
  description = "ARN of the branches ETL lambda"
}

variable "branches_lambda_name" {
  type = string
  description = "Name of the branches ETL lambda"
}

variable "step_function_arn_post" {
  type = string
  description = "ARN of the step function to be triggered"
}

variable "environment" {
  type        = string
  description = "Execution environment"
}
