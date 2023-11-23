###########################################################
# Run a Full Index every day at 4:00 CT (10:00 UTC)
###########################################################
resource "aws_cloudwatch_event_rule" "nightly" {
  name = "nightly"
  description = "Every night at 4:00 CT"

  schedule_expression = "cron(45 10 * * ? *)"
}

resource "aws_cloudwatch_event_rule" "post-pim" {
  name = "post-pim-update"
  description = "Every night at 10:45 am UTC"

  schedule_expression = "cron(45 10 * * ? *)"
}


resource "aws_cloudwatch_event_target" "post-etl-step-function-daily" {
  count = var.environment == "prod" ? 1 : 0 
  rule = aws_cloudwatch_event_rule.post-pim.name
  input = "{\"full_refresh\":false}"
  target_id = "TriggerPostETLStepFunctionDaily"
  arn = var.step_function_arn_post
  role_arn = aws_iam_role.cloudwatch-role.arn
}

resource "aws_cloudwatch_event_rule" "fullrebuild" {
  name = "fullrebuild"
  description = "Every night at 10:30 am UTC"

  schedule_expression = "cron(30 10 * * ? *)"
}


# resource "aws_cloudwatch_event_target" "product-etl-step-function-nightly" {
#   rule = aws_cloudwatch_event_rule.nightly.name
#   input = "{\"fetchAll\":true,\"indexAll\":true}"
#   target_id = "TriggerProductETLStepFunctionNightly"
#   arn = var.step_function_arn
#   role_arn = aws_iam_role.cloudwatch-role.arn
# }

resource "aws_cloudwatch_event_target" "product-etl-step-function-nightly-mincron" {
  rule = aws_cloudwatch_event_rule.fullrebuild.name
  input = "{\"fetchAll\":true,\"indexAll\":true}"
  target_id = "TriggerProductETLStepFunctionNightlyMincron"
  arn = var.step_function_arn_mincron
  role_arn = aws_iam_role.cloudwatch-role.arn
}

resource "aws_cloudwatch_event_target" "product-etl-step-function-nightly-bk" {
  rule = aws_cloudwatch_event_rule.nightly.name
  input = "{\"fetchAll\":true,\"indexAll\":true}"
  target_id = "TriggerProductETLStepFunctionNightlyBK"
  arn = var.step_function_arn_bk
  role_arn = aws_iam_role.cloudwatch-role.arn
}

###########################################################
# Run a Partial Index every day at every hour except 4:00 CT (10:00 UTC)
###########################################################
resource "aws_cloudwatch_event_rule" "hourly" {
  name = "hourly"
  description = "Every hour except at 4:00 CT"

  schedule_expression = "cron(45 0-9,11-23 * * ? *)"
}

# resource "aws_cloudwatch_event_target" "product-etl-step-function-hourly" {
#   rule = aws_cloudwatch_event_rule.hourly.name
#   input = "{\"fetchAll\":false,\"indexAll\":false}"
#   target_id = "TriggerProductETLStepFunctionHourly"
#   arn = var.step_function_arn
#   role_arn = aws_iam_role.cloudwatch-role.arn
# }

resource "aws_cloudwatch_event_target" "product-etl-step-function-hourly-mincron" {
  rule = aws_cloudwatch_event_rule.hourly.name
  input = "{\"fetchAll\":false,\"indexAll\":false}"
  target_id = "TriggerProductETLStepFunctionHourlyMincron"
  arn = var.step_function_arn_mincron
  role_arn = aws_iam_role.cloudwatch-role.arn
}

resource "aws_cloudwatch_event_target" "product-etl-step-function-hourly-bk" {
  rule = aws_cloudwatch_event_rule.hourly.name
  input = "{\"fetchAll\":false,\"indexAll\":false}"
  target_id = "TriggerProductETLStepFunctionHourlyBK"
  arn = var.step_function_arn_bk
  role_arn = aws_iam_role.cloudwatch-role.arn
}

# resource "aws_cloudwatch_event_target" "branches-etl-target" {
#   rule = aws_cloudwatch_event_rule.nightly.name
#   target_id = "TriggerBranchesETLLambda"
#   arn = var.branches_lambda_arn
# }

resource "aws_lambda_permission" "branches_lambda_permission" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = var.branches_lambda_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.nightly.arn
}

resource "aws_iam_role" "cloudwatch-role" {
  name = "cloudwatch-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "states.amazonaws.com",
          "events.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "cloudwatch-product-etl-policy" {
  name = "cloudwatch-product-etl-policy"
  path = "/"
  description = "IAM plicy for triggering step function from a Cloudwatch event"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "states:SendTaskSuccess",
              "states:ListStateMachines",
              "states:SendTaskFailure",
              "states:ListActivities",
              "states:SendTaskHeartbeat"
          ],
          "Resource": "*"
      },
      {
          "Effect": "Allow",
          "Action": "states:*",
          "Resource": [
              "arn:aws:states:*:490524275591:execution:*:*",
              "arn:aws:states:*:490524275591:stateMachine:*"
          ]
      }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AmazonStepFunctionsPolicy" {
  policy_arn = aws_iam_policy.cloudwatch-product-etl-policy.arn
  role = aws_iam_role.cloudwatch-role.name
}
