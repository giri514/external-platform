output "post_api_policy_arn" {
  description = "IAM Policy allowing get and put access"
  value       = aws_iam_policy.post_api_secretmanager_get.arn
}

output "step_function_arn_post" {
  description = "The ARN of the step function for mincron"
  value = aws_sfn_state_machine.sfn_state_machine_post.arn
}
