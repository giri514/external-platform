# Persistent volume claim for Grafana
resource "kubernetes_persistent_volume_claim" "grafana-stack-pvc" {
  metadata {
    name = "grafana-stack-pvc"
    annotations = {
      "volume.beta.kubernetes.io/storage-class" = "ebs-storage-class"
    }
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      vol = "grafana-stack-pvc"
    }
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    volume_name        = "grafana-stack-pv"
    storage_class_name = "ebs-storage-class"
    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }
  depends_on = [
    kubernetes_namespace.monitoring,
    kubernetes_persistent_volume.grafana-stack-pv
  ]
}