resource "aws_iam_openid_connect_provider" "main" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.main.certificates[0].sha1_fingerprint]
  url             = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer

  lifecycle {
    ignore_changes = [thumbprint_list]
  }

  tags = {}
}

data "tls_certificate" "main" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.main.id
}

data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.main.id
}

resource "aws_iam_policy" "AmazonEKSClusterCloudWatchMetricsPolicy" {
  name   = "AmazonEKSClusterCloudWatchMetricsPolicy"
  policy = file("${path.module}/policies/eks_cluster_cloud_watch_metrics_policy.json")
  tags   = {}
}

resource "aws_iam_policy" "AmazonEKSClusterNLBPolicy" {
  name   = "AmazonEKSClusterNLBPolicy"
  policy = file("${path.module}/policies/eks_cluster_nlb_policy.json")
  tags   = {}
}

resource "aws_iam_role" "eks_cluster_role" {
  name                  = "${var.name}-eks-cluster-role"
  force_detach_policies = true
  assume_role_policy    = file("${path.module}/policies/eks_cluster_role_policy.json")
  tags                  = {}
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSCloudWatchMetricsPolicy" {
  policy_arn = aws_iam_policy.AmazonEKSClusterCloudWatchMetricsPolicy.arn
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSCluserNLBPolicy" {
  policy_arn = aws_iam_policy.AmazonEKSClusterNLBPolicy.arn
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = "/aws/eks/${var.name}-${var.environment}/cluster"
  retention_in_days = 30

  tags = {
    Name        = "${var.name}-${var.environment}-eks-cloudwatch-log-group"
    Environment = var.environment
  }
}

resource "aws_eks_cluster" "main" { #tfsec:ignore:aws-eks-no-public-cluster-access tfsec:ignore:aws-eks-encrypt-secrets 
  name     = "${var.name}-${var.environment}"
  role_arn = aws_iam_role.eks_cluster_role.arn

  version = var.kubernetes_version

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_config { #tfsec:ignore:aws-eks-no-public-cluster-access-to-cidr
    subnet_ids         = concat(var.public_subnets[*].id, var.private_subnets[*].id)
    security_group_ids = []
  }

  timeouts {
    delete = "30m"
  }

  tags = {}

  depends_on = [
    aws_cloudwatch_log_group.eks_cluster,
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy
  ]
}

data "template_file" "kubeconfig" {
  template = file("${path.module}/templates/kubeconfig.tpl")

  vars = {
    kubeconfig_name     = "eks_${aws_eks_cluster.main.name}"
    clustername         = aws_eks_cluster.main.name
    endpoint            = data.aws_eks_cluster.cluster.endpoint
    cluster_auth_base64 = data.aws_eks_cluster.cluster.certificate_authority[0].data
  }
}

resource "local_file" "kubeconfig" {
  content  = data.template_file.kubeconfig.rendered
  filename = pathexpand("${var.kubeconfig_path}/config")
}

resource "kubernetes_namespace" "services" {
  metadata {
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
    annotations = {}
    name        = "${var.name}-${var.environment}"
  }
}
