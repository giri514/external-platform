// Lambda function
locals {
  branch-data = jsondecode(data.aws_secretsmanager_secret_version.branch-data.secret_string)
}

resource "aws_lambda_function" "lambda_branch_data" {
  function_name = "${var.lambda_function_branch_data_name}_${var.environment}"
  filename      = data.archive_file.dummy2.output_path
  publish       = true
  handler       = "index.handler"
  role          = aws_iam_role.lambda_branch_data_assume_role.arn
  runtime       = "nodejs18.x"
  timeout       = 900 // Number of seconds. 900 = 15 minutes
  memory_size   = 3008

  vpc_config {
    subnet_ids         = var.private_subnets.*.id
    security_group_ids = [aws_security_group.private_lambda_security_group.id]
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      version,
      qualified_arn,
      filename
    ]
  }

  environment {
    variables = {
      GOOGLE_API_KEY = local.branch-data.GOOGLE_API_KEY
      PG_DATABASE    = local.branch-data.PG_DATABASE
      PG_HOST        = local.branch-data.PG_HOST
      PG_PASSWORD    = local.branch-data.PG_PASSWORD
      PG_USER        = local.branch-data.PG_USER
      SF_ACCOUNT     = local.branch-data.SF_ACCOUNT
      SF_DATABASE    = local.branch-data.SF_DATABASE
      SF_PASSWORD    = local.branch-data.SF_PASSWORD
      SF_SCHEMA      = local.branch-data.SF_SCHEMA
      SF_USER        = local.branch-data.SF_USER
    }
  }
}

// Zip of lambda handler
data "archive_file" "dummy3" {
  output_path = "${path.module}/lambda.zip"
  type        = "zip"

  source {
    content  = "hello"
    filename = "dummy2.txt"
  }
}

// Lambda IAM assume role
resource "aws_iam_role" "lambda_branch_data_assume_role" {
  name               = "${var.lambda_function_branch_data_name}-assume-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_branch_data_assume_role_policy_document.json

  lifecycle {
    create_before_destroy = true
  }
}

// IAM policy document for lambda assume role
data "aws_iam_policy_document" "lambda_branch_data_assume_role_policy_document" {
  version = "2012-10-17"

  statement {
    sid     = "LambdaAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_policy" "branch_lambda_policies" {
  name        = "${var.lambda_function_branch_data_name}-policy"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "allow_logs_branch_data" {
  role       = aws_iam_role.lambda_branch_data_assume_role.name
  policy_arn = aws_iam_policy.branch_lambda_policies.arn
}

resource "aws_iam_role_policy_attachment" "AWSLambdaVPCAccessExecutionRoleBranchData" {
  role       = aws_iam_role.lambda_branch_data_assume_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
