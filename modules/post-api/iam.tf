
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "post_api_secretmanager_get" {
  version = "2012-10-17"

  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:List*",
      "secretsmanager:GetSecretValue"
    ]

    resources = ["arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:post-api*"]
  }
}

resource "aws_iam_policy" "post_api_secretmanager_get" {
  name   = "post-api-secretmanager-get"
  policy = data.aws_iam_policy_document.post_api_secretmanager_get.json
}
