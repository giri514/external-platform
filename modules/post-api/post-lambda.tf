// Lambda function
resource "aws_lambda_function" "lambda_function_post" {
  function_name = "${var.lambda_function_post_name}-${var.environment}"
  image_uri     = "694955555685.dkr.ecr.us-east-1.amazonaws.com/reece/post-api-service:0.2.0-lambda" # place holder, is updated by Application CI/CD pipeline
  role          = aws_iam_role.lambda_assume_role_post.arn
  package_type  = "Image"
  timeout       = 900 // Number of seconds. 900 = 15 minutes
  memory_size   = 3008

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      version,
      qualified_arn,
      image_uri
    ]
  }

  environment {
    variables = {
      POST_ENV     = "LAMBDA"
      SECRETS_MANAGER_KEY    = "post-api"
    }
  }
}



// Lambda IAM assume role
resource "aws_iam_role" "lambda_assume_role_post" {
  name               = "${var.lambda_function_post_name}-assume-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_post_assume_role_policy_document.json

  lifecycle {
    create_before_destroy = true
  }
}

// IAM policy document for lambda assume role
data "aws_iam_policy_document" "lambda_post_assume_role_policy_document" {
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

resource "aws_iam_policy" "lambda_logs_policy_post" {
  name        = "${var.lambda_function_post_name}-logs-policy"
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

resource "aws_iam_policy" "lambda_s3_policy_post" {
  name        = "${var.lambda_function_post_name}-s3-policy"
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
    },
    {
      "Action": [
        "secretsmanager:DescribeSecret",
        "secretsmanager:List*",
        "secretsmanager:GetSecretValue"
        ],
      "Effect": "Allow",
      "Resource": "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:post-api*"
    },
    {
        "Action": "iam:PassRole",
        "Effect": "Allow",
        "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:SetRepositoryPolicy",
        "ecr:GetRepositoryPolicy",
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer"
      ],
      "Resource": "arn:aws:ecr:us-east-1:694955555685:repository/reece/post-api-service"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "allow_logs_post" {
  role       = aws_iam_role.lambda_assume_role_post.name
  policy_arn = aws_iam_policy.lambda_logs_policy_post.arn
}

resource "aws_iam_role_policy_attachment" "allow_s3_post" {
  role       = aws_iam_role.lambda_assume_role_post.name
  policy_arn = aws_iam_policy.lambda_s3_policy_post.arn
}

resource "aws_iam_role_policy_attachment" "AWSLambdaExecutionRoleExtractPost" {
  role       = aws_iam_role.lambda_assume_role_post.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


