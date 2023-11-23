// Lambda function
locals {
  category-data = jsondecode(data.aws_secretsmanager_secret_version.category-data.secret_string)
}

resource "aws_lambda_function" "lambda_category_data" {
  function_name = "${var.lambda_function_category_data_name}_${var.environment}"
  filename      = data.archive_file.dummy2.output_path
  publish       = true
  handler       = "index.handler"
  role          = aws_iam_role.lambda_category_data_assume_role.arn
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
      POSTGRES_DB           = local.category-data.POSTGRES_DB
      POSTGRES_HOST         = local.category-data.POSTGRES_HOST
      POSTGRES_PASSWORD     = local.category-data.POSTGRES_PASSWORD
      POSTGRES_USER         = local.category-data.POSTGRES_USER
      SNOWFLAKE_ACCOUNT     = local.category-data.SNOWFLAKE_ACCOUNT
      SNOWFLAKE_DB          = local.category-data.SNOWFLAKE_DB
      SNOWFLAKE_PASSWORD    = local.category-data.SNOWFLAKE_PASSWORD
      SNOWFLAKE_SCHEMA      = local.category-data.SNOWFLAKE_SCHEMA
      SNOWFLAKE_USERNAME    = local.category-data.SNOWFLAKE_USERNAME
      WATERWORKS_SERVER     = local.category-data.WATERWORKS_SERVER
      WATERWORKS_USERNAME   = local.category-data.WATERWORKS_USERNAME
      WATERWORKS_PASSWORD   = local.category-data.WATERWORKS_PASSWORD
      WATERWORKS_DB         = local.category-data.WATERWORKS_DB
    }
  }
}

// Zip of lambda handler
data "archive_file" "dummy4" {
  output_path = "${path.module}/lambda.zip"
  type        = "zip"

  source {
    content  = "hello"
    filename = "dummy2.txt"
  }
}

// Lambda IAM assume role
resource "aws_iam_role" "lambda_category_data_assume_role" {
  name               = "${var.lambda_function_category_data_name}-assume-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_category_data_assume_role_policy_document.json

  lifecycle {
    create_before_destroy = true
  }
}

// IAM policy document for lambda assume role
data "aws_iam_policy_document" "lambda_category_data_assume_role_policy_document" {
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

resource "aws_iam_policy" "category_lambda_policies" {
  name        = "${var.lambda_function_category_data_name}-policy"
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

resource "aws_iam_role_policy_attachment" "allow_logs_category_data" {
  role       = aws_iam_role.lambda_category_data_assume_role.name
  policy_arn = aws_iam_policy.category_lambda_policies.arn
}

resource "aws_iam_role_policy_attachment" "AWSLambdaVPCAccessExecutionRoleCategoryData" {
  role       = aws_iam_role.lambda_category_data_assume_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
