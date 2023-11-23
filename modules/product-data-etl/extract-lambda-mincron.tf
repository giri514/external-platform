// Lambda function
resource "aws_lambda_function" "lambda_function_extract_mincron" {
  function_name = "${var.lambda_function_extract_name_mincron}_${var.environment}"
  filename      = data.archive_file.dummy1_mincron.output_path
  publish       = true
  handler       = "extract.lambda_handler"
  role          = aws_iam_role.lambda_extract_assume_role_mincron.arn
  runtime       = "python3.8"
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
      ECLIPSE_PRODUCTS_SERVER     = sensitive(local.product-etl.ECLIPSE_PRODUCTS_SERVER)
      ECLIPSE_PRODUCTS_USERNAME   = sensitive(local.product-etl.ECLIPSE_PRODUCTS_USERNAME)
      ECLIPSE_PRODUCTS_PASSWORD   = sensitive(local.product-etl.ECLIPSE_PRODUCTS_PASSWORD)
      ECLIPSE_PRODUCTS_DATABASE   = sensitive(local.product-etl.ECLIPSE_PRODUCTS_DATABASE)
      TARGET_BUCKET     = "${aws_s3_bucket.data_storage_mincron.id}"
      ENVIRONMENT       = local.product-etl.ENVIRONMENT
      ACCESS_KEY_ID     = sensitive(local.product-etl.AWS_ACCESS_KEY_ID)
      SECRET_ACCESS_KEY = sensitive(local.product-etl.AWS_SECRET_ACCESS_KEY)
    }
  }
}

// Zip of lambda handler - dummy file for initialization only
data "archive_file" "dummy1_mincron" {
  output_path = "${path.module}/lambda.zip"
  type        = "zip"

  source {
    content  = "hello"
    filename = "dummy1.txt"
  }
}

// Latest version of odbc layer
data "aws_lambda_layer_version" "latest-odbc" {
  layer_name = "odbc-layer"
  depends_on = [
    aws_lambda_layer_version.odbc-layer,
  ]
}

// Initial creation of lambda layer
resource "aws_lambda_layer_version" "odbc-layer" {
  layer_name          = "odbc-layer"
  filename            = data.archive_file.dummy1_mincron.output_path
  compatible_runtimes = ["python3.8"]
  skip_destroy        = true
}


// Lambda IAM assume role
resource "aws_iam_role" "lambda_extract_assume_role_mincron" {
  name               = "${var.lambda_function_extract_name_mincron}-assume-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_extract_assume_role_policy_document_mincron.json

  lifecycle {
    create_before_destroy = true
  }
}

// IAM policy document for lambda assume role
data "aws_iam_policy_document" "lambda_extract_assume_role_policy_document_mincron" {
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

resource "aws_iam_policy" "extract_lambda_logs_policy_mincron" {
  name        = "${var.lambda_function_extract_name_mincron}-logs-policy"
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

resource "aws_iam_policy" "extract_lambda_s3_policy_mincron" {
  name        = "${var.lambda_function_extract_name_mincron}-s3-policy"
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

resource "aws_iam_role_policy_attachment" "allow_logs_extract_mincron" {
  role       = aws_iam_role.lambda_extract_assume_role_mincron.name
  policy_arn = aws_iam_policy.extract_lambda_logs_policy_mincron.arn
}

resource "aws_iam_role_policy_attachment" "allow_s3_extract_mincron" {
  role       = aws_iam_role.lambda_extract_assume_role_mincron.name
  policy_arn = aws_iam_policy.extract_lambda_s3_policy_mincron.arn
}

resource "aws_iam_role_policy_attachment" "AWSLambdaVPCAccessExecutionRoleExtractMincron" {
  role       = aws_iam_role.lambda_extract_assume_role_mincron.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}


