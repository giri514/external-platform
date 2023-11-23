output "step_function_arn" {
  description = "The ARN of the step function"
  value = aws_sfn_state_machine.sfn_state_machine.arn
}

output "step_function_arn_mincron" {
  description = "The ARN of the step function for mincron"
  value = aws_sfn_state_machine.sfn_state_machine_mincron.arn
}

output "step_function_arn_bk" {
  description = "The ARN of the step function for mincron"
  value = aws_sfn_state_machine.sfn_state_machine_bk.arn
}

output "branches_lambda_arn" {
  description = "The ARN of the branches ETL labmda"
  value = aws_lambda_function.lambda_branch_data.arn
}

output "branches_lambda_name" {
  description = "The name of the branches ETL labmda"
  value = aws_lambda_function.lambda_branch_data.function_name
}