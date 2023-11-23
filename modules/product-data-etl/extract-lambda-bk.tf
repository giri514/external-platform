// Lambda function
resource "aws_lambda_function" "lambda_function_extract_bk" {
  function_name = "${var.lambda_function_extract_name_bk}_${var.environment}"
  filename      = data.archive_file.dummy1.output_path
  publish       = true
  handler       = "index.handler"
  role          = aws_iam_role.lambda_extract_assume_role_bk.arn
  runtime       = "nodejs18.x"
  timeout       = 899 // Number of seconds. 900 = 15 minutes
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
      ACCOUNT           = local.product-etl.ACCOUNT
      USERNAME          = local.product-etl.USERNAME
      PASSWORD          = local.product-etl.PASSWORD
      DATABASE          = local.product-etl.DATABASE
      SCHEMA            = local.product-etl.SCHEMA
      ENVIRONMENT       = local.product-etl.ENVIRONMENT
      ACCESS_KEY_ID     = local.product-etl.AWS_ACCESS_KEY_ID
      SECRET_ACCESS_KEY = local.product-etl.AWS_SECRET_ACCESS_KEY
      BUCKET_NAME =     "${aws_s3_bucket.data_storage_bk.id}"
    }
  }
}

// Lambda IAM assume role
resource "aws_iam_role" "lambda_extract_assume_role_bk" {
  name               = "${var.lambda_function_extract_name_bk}-assume-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_extract_assume_role_policy_document_bk.json

  lifecycle {
    create_before_destroy = true
  }
}

// IAM policy document for lambda assume role
data "aws_iam_policy_document" "lambda_extract_assume_role_policy_document_bk" {
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

resource "aws_iam_policy" "extract_lambda_logs_policy_bk" {
  name        = "${var.lambda_function_extract_name_bk}-logs-policy"
  path        = "/"
  description = "IAM policy for extract lambda"
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

resource "aws_iam_policy" "extract_lambda_s3_policy_bk" {
  name        = "${var.lambda_function_extract_name_bk}-s3-policy"
  path        = "/"
  description = "IAM policy for extract lambda"
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

resource "aws_iam_role_policy_attachment" "allow_logs_extract_bk" {
  role       = aws_iam_role.lambda_extract_assume_role_bk.name
  policy_arn = aws_iam_policy.extract_lambda_logs_policy_bk.arn
}

resource "aws_iam_role_policy_attachment" "allow_s3_extract_bk" {
  role       = aws_iam_role.lambda_extract_assume_role_bk.name
  policy_arn = aws_iam_policy.extract_lambda_s3_policy_bk.arn
}

resource "aws_iam_role_policy_attachment" "AWSLambdaVPCAccessExecutionRoleExtractBK" {
  role       = aws_iam_role.lambda_extract_assume_role_bk.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}


