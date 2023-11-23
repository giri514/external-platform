resource "kubernetes_namespace" "kubernetes_dashboard" {
  metadata {
    name = "kubernetes-dashboard"
  }
}

resource "helm_release" "kubernetes_dashboard" {
  name       = "kubernetes-dashboard"
  repository = "https://kubernetes.github.io/dashboard/"
  chart      = "kubernetes-dashboard"

  depends_on = [kubernetes_namespace.kubernetes_dashboard]
  namespace  = kubernetes_namespace.kubernetes_dashboard.metadata[0].name


  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "service.externalPort"
    value = "9080"
  }

  set {
    name  = "protocolHttp"
    value = "true"
  }

  set {
    name  = "enableInsecureLogin"
    value = "true"
  }

  set {
    name  = "rbac.clusterReadOnlyRole"
    value = "true"
  }

  set {
    name  = "metricsScraper.enabled"
    value = "true"
  }

  wait = true
}
