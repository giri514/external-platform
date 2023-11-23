// Lambda function
resource "aws_lambda_function" "lambda_function_index_mincron" {
  function_name = "${var.lambda_function_index_name_mincron}_${var.environment}"
  filename      = data.archive_file.dummy2_mincron.output_path
  publish       = true
  handler       = "index.handler"
  role          = aws_iam_role.lambda_index_assume_role_mincron.arn
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
      BUCKET_NAME = "${aws_s3_bucket.data_storage_mincron.id}"
      ES_API_KEY = local.product-etl.ES_API_KEY
      ES_URL = local.product-etl.ES_URL
    }
  }
}

// Zip of lambda handler - dummy file for initialization only
data "archive_file" "dummy2_mincron" {
  output_path = "${path.module}/lambda.zip"
  type        = "zip"

  source {
    content  = "hello"
    filename = "dummy2.txt"
  }
}

// Lambda IAM assume role
resource "aws_iam_role" "lambda_index_assume_role_mincron" {
  name               = "${var.lambda_function_index_name_mincron}-assume-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_index_assume_role_policy_document_mincron.json

  lifecycle {
    create_before_destroy = true
  }
}

// IAM policy document for lambda assume role
data "aws_iam_policy_document" "lambda_index_assume_role_policy_document_mincron" {
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

resource "aws_iam_policy" "index_lambda_policies_mincron" {
  name        = "${var.lambda_function_index_name_mincron}-policy"
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

resource "aws_iam_policy" "index_lambda_s3_policy_mincron" {
  name        = "${var.lambda_function_index_name_mincron}-s3-policy"
  path        = "/"
  description = "IAM policy for index lambda"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "s3:*",
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "allow_logs_index_mincron" {
  role       = aws_iam_role.lambda_index_assume_role_mincron.name
  policy_arn = aws_iam_policy.index_lambda_policies_mincron.arn
}

resource "aws_iam_role_policy_attachment" "allow_s3_index_mincron" {
  role       = aws_iam_role.lambda_index_assume_role_mincron.name
  policy_arn = aws_iam_policy.index_lambda_s3_policy_mincron.arn
}

resource "aws_iam_role_policy_attachment" "AWSLambdaVPCAccessExecutionRoleIndexMincron" {
  role       = aws_iam_role.lambda_index_assume_role_mincron.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
