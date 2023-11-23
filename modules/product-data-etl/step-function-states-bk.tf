resource "aws_sfn_state_machine" "sfn_state_machine_bk" {
  name     = var.step_function_name_bk
  role_arn = aws_iam_role.step_function_role_bk.arn

  definition = <<EOF
  {
    "Comment": "Invoke AWS Lambda from AWS Step Functions with Terraform",
    "StartAt": "Extract",
    "States": {
      "Extract": {
        "Type": "Task",
        "Resource": "${aws_lambda_function.lambda_function_extract_bk.arn}",
        "Next": "ConfigureIndex",
        "Retry": [ {
          "ErrorEquals": [ "States.Timeout" ],
          "IntervalSeconds": 300,
          "MaxAttempts": 3,
          "BackoffRate": 1.5
        } ]
      },
      "ConfigureIndex": {
        "Type": "Choice",
        "Choices": [
          {
            "Variable": "$.reindexAll",
            "BooleanEquals": true,
            "Next": "RebuildIndex"
          },
          {
            "Variable": "$.reindexAll",
            "BooleanEquals": false,
            "Next": "Reindex"
          }
        ],
        "Default": "Reindex"
      },
      "RebuildIndex": {
        "Type": "Pass",
        "Result": {
          "fileIndex": "0",
          "chunkSize": "1",
          "indexAll": true
        },
        "Next": "Index"
      },
      "Reindex": {
        "Type": "Pass",
        "Result": {
          "fileIndex": "0",
          "chunkSize": "1"
        },
        "Next": "Index"
      },
      "Index": {
        "Type": "Task",
        "Resource": "${aws_lambda_function.lambda_function_index_bk.arn}",
        "Next": "ShouldContinueIndex"
      },
      "ShouldContinueIndex": {
        "Type": "Choice",
        "Choices": [
          {
            "Variable": "$.shouldContinue",
            "BooleanEquals": true,
            "Next": "Index"
          }
        ],
        "Default": "Done"
      },
      "Done": {
        "Type": "Pass",
        "End": true
      }
    }
  }
  EOF
}

resource "aws_iam_role" "step_function_role_bk" {
  name               = "${var.step_function_name_bk}-role"
  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "states.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": "StepFunctionAssumeRole"
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy" "step_function_policy_extract_bk" {
  name = "${var.step_function_name_bk}-extract-policy"
  role = aws_iam_role.step_function_role_bk.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "lambda:InvokeFunction"
        ],
        "Effect": "Allow",
        "Resource": "${aws_lambda_function.lambda_function_extract_bk.arn}"
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy" "step_function_policy_index_bk" {
  name = "${var.step_function_name_bk}-index-policy"
  role = aws_iam_role.step_function_role_bk.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "lambda:InvokeFunction"
        ],
        "Effect": "Allow",
        "Resource": "${aws_lambda_function.lambda_function_index_bk.arn}"
      }
    ]
  }
  EOF
}
