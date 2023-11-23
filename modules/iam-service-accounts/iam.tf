provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  version                = "~> 2.15"
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_id
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "post_api_service_role" {
  name        = "post-api-service-role"
  description = "IAM role for the post-api k8s service account."

  force_detach_policies = true

  assume_role_policy = <<ROLE
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:aud": "sts.amazonaws.com",
          "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:sub": "${var.post_api_k8s_service_account}"
        }
      }
    }
  ]
}
ROLE
}

resource "aws_iam_role_policy_attachment" "post_api_service_account" {
  role       = aws_iam_role.post_api_service_role.name
  policy_arn = var.post_api_policy_arn
}
