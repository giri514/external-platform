# Notes on installing Jaeger via Helm:
# - This will install a daemonset, which is not applicable to Fargate EKS.
# - So, after installing, do a kubectl delete daemonset jaeger-agent.
# - Jaeger-agent is responsible for collecting traces from localhost. Instead, configure services to send traces directly to jaeger-collector service.
resource "helm_release" "jaeger-tracing" {
  name       = "jaeger-tracing"
  repository = "https://jaegertracing.github.io/helm-charts"
  chart      = "jaeger"

  depends_on = [kubernetes_namespace.monitoring]
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
}
