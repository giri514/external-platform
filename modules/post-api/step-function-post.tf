resource "aws_sfn_state_machine" "sfn_state_machine_post" {
  name     = var.step_function_name_post
  role_arn = aws_iam_role.step_function_role_post.arn

  definition = <<EOF
  {
  "StartAt": "PDWDownloader",
  "States": {
    "PDWDownloader": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.lambda_function_post.arn}",
      "Parameters": {
        "full_refresh.$": "$.full_refresh",
        "function": "pdw"
      },
      "ResultSelector": {
        "s3_file.$": "$.s3_file"
      },
      "ResultPath": "$.PDWDownloaderOutput",
      "Next": "CreateIndex"
    },
    "CreateIndex": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.lambda_function_post.arn}",
      "Parameters": {
        "function": "create-index"
      },
      "ResultSelector": {
        "index_name.$": "$.index_name"
      },
      "ResultPath": "$.CreateIndexOutput",
      "Next": "Batcher"
    },
    "Batcher": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.lambda_function_post.arn}",
      "Parameters": {
        "index_name.$": "$.CreateIndexOutput.index_name",
        "s3_file.$": "$.PDWDownloaderOutput.s3_file",
        "function": "batcher"
      },
      "ResultPath": "$.batcherOutput",
      "Next": "ProcessChunks"
    },
    "ProcessChunks": {
      "Type": "Map",
      "ItemsPath": "$.batcherOutput.batches",
      "ResultPath": null,
      "Parameters": {
        "index_name.$": "$.CreateIndexOutput.index_name",
        "batch.$": "$$.Map.Item.Value",
        "function": "process"
      },
      "MaxConcurrency": 350,
      "Iterator": {
        "ProcessorConfig": {
          "Mode": "DISTRIBUTED",
          "ExecutionType": "STANDARD"
        },
        "StartAt": "Consumer",
        "States": {
          "Consumer": {
            "Type": "Task",
            "ResultPath":null,
            "Resource": "${aws_lambda_function.lambda_function_post.arn}",
            "End": true
          }
        }
      },
      "Retry": [
        {
          "ErrorEquals": ["States.ALL"],
          "MaxAttempts": 3
        }
      ],
      "Next": "Scoring"
    },
    "Scoring": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.lambda_function_post.arn}",
      "Parameters": {
        "index_name.$": "$.CreateIndexOutput.index_name",
        "s3_file.$": "$.PDWDownloaderOutput.s3_file",
        "function": "score"
      },
      "ResultPath": "$.scoringOutput",
      "Next": "PostProcessor"
    },
    "PostProcessor": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.lambda_function_post.arn}",
      "Parameters": {
        "index_name.$": "$.CreateIndexOutput.index_name",
        "s3_file.$": "$.PDWDownloaderOutput.s3_file",
        "function": "migrate-index"
      },
      "End": true
    }
  }
}
  EOF
}

data "aws_iam_policy_document" "sfn_post_assume_role_policy_document" {
  version = "2012-10-17"
  statement {
    sid     = "StepFunctionAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["states.amazonaws.com"]
      type        = "Service"
    }
  }
}


resource "aws_iam_role" "step_function_role_post" {
  name               = "${var.step_function_name_post}-role"
  assume_role_policy = data.aws_iam_policy_document.sfn_post_assume_role_policy_document.json
}

resource "aws_iam_role_policy" "step_function_policy_post" {
  name = "${var.step_function_name_post}-policy"
  role = aws_iam_role.step_function_role_post.id

  policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "lambda:InvokeFunction"
      ],
      "Effect": "Allow",
      "Resource": "${aws_lambda_function.lambda_function_post.arn}"
    },
    {
      "Action": [
        "events:*","states:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
  EOF
}
