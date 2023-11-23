provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

data "aws_caller_identity" "current" {}

resource "helm_release" "aws-load-balancer-controller" {
  name = "aws-load-balancer-controller"
  depends_on = [
    aws_iam_role.AmazonEKSLoadBalancerControllerRole,
    local_file.kubeconfig
  ]

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = aws_eks_cluster.main.name
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.AmazonEKSLoadBalancerControllerRole.arn
  }

  set {
    name  = "image.repository"
    value = format("602401143452.dkr.ecr.%s.amazonaws.com/amazon/aws-load-balancer-controller", var.aws_region)
  }

  set {
    name  = "region"
    value = var.aws_region
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }

  set {
    name  = "image.tag"
    value = "v2.5.2"
  }
}

resource "aws_iam_policy" "aws_load_balancer_controller_iam_policy" {
  name   = "aws_load_balancer_controller_iam_policy"
  policy = file("${path.module}/policies/eks_load_balancer_controller_policy.json")
  tags   = {}
}

resource "aws_iam_policy" "aws_load_balancer_controller_iam_additional_policy" {
  name   = "aws_load_balancer_controller_iam_additional_policy"
  policy = file("${path.module}/policies/eks_load_balancer_controller_additional_policy.json")
  tags   = {}
}

resource "aws_iam_role" "AmazonEKSLoadBalancerControllerRole" {
  name               = "AmazonEKSLoadBalancerControllerRole"
  description        = "Permissions required by the Kubernetes AWS Load Balancer controller to do it's job."
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
          "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
        }
      }
    }
  ]
}
ROLE
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller_iam_policy" {
  policy_arn = aws_iam_policy.aws_load_balancer_controller_iam_policy.arn
  role       = aws_iam_role.AmazonEKSLoadBalancerControllerRole.name
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller_iam_additional_policy" {
  policy_arn = aws_iam_policy.aws_load_balancer_controller_iam_additional_policy.arn
  role       = aws_iam_role.AmazonEKSLoadBalancerControllerRole.name
}


