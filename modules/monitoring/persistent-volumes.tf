# EBS Volume for persistent storage for Grafana
resource "aws_ebs_volume" "grafana-stack-ebs" { #tfsec:ignore:aws-ec2-enable-volume-encryption
  availability_zone = var.availability_zones[0]
  size              = 10

  tags = {
    Name          = "${var.name}-${var.environment}-grafana-stack-ebs"
    Environment   = var.environment
    "Group Owner" = "Reece"
    "VPC Name"    = "${var.name}-${var.environment}-vpc}"
  }
}

# EBS Volume for persistent storage for Prometheus
resource "aws_ebs_volume" "prometheus-stack-ebs" { #tfsec:ignore:aws-ec2-enable-volume-encryption
  availability_zone = var.availability_zones[0]
  size              = 10

  tags = {
    Name          = "${var.name}-${var.environment}-prometheus-stack-ebs"
    Environment   = var.environment
    "Group Owner" = "Reece"
    "VPC Name"    = "${var.name}-${var.environment}-vpc}"
  }
}

# Create storage class in k8s. This is the k8s counterpart to EFS.
resource "kubernetes_storage_class" "ebs-storage-class" {
  metadata {
    name = "ebs-storage-class"
  }
  storage_provisioner = "ebs.csi.aws.com"
  parameters = {
    type = "gp2"
  }
  reclaim_policy = "Retain"
}

# Persistent volume for Grafana
resource "kubernetes_persistent_volume" "grafana-stack-pv" {
  metadata {
    name = "grafana-stack-pv"
  }
  spec {
    storage_class_name = "ebs-storage-class"
    capacity = {
      storage = "10Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_source {
      aws_elastic_block_store {
        volume_id = aws_ebs_volume.grafana-stack-ebs.id
      }
    }
  }
}

# Persistent volume for Prometheus
resource "kubernetes_persistent_volume" "prometheus-stack-pv" {
  metadata {
    name = "prometheus-stack-pv"
    labels = {
      app = "prometheus-stack"
    }
  }
  spec {
    storage_class_name = "ebs-storage-class"
    capacity = {
      storage = "10Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_source {
      aws_elastic_block_store {
        volume_id = aws_ebs_volume.prometheus-stack-ebs.id
      }
    }
  }
}
