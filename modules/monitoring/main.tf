provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_id
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "cluster_prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  wait       = false

  depends_on = [kubernetes_namespace.monitoring]
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  values = [templatefile("${path.module}/templates/prometheus.yaml", {
    environment       = var.environment,
    availability_zone = var.availability_zones[0]
    cert_arn          = var.cert_arn
  })]
}
