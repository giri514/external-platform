# Namespce - name must be aws-observability
resource "kubernetes_namespace" "aws-observability" {
  metadata {
    name = "aws-observability"
    labels = {
      "aws-observability" = "enabled"
    }
  }
}

# Configmap for Fargate logging
resource "kubernetes_config_map" "fluent-bit-configmap" {
  depends_on = [
    kubernetes_namespace.aws-observability
  ]

  metadata {
    name      = "aws-logging"
    namespace = "aws-observability"
  }

  data = {
    "output.conf"  = <<EOF
[OUTPUT]
    Name cloudwatch_logs
    Match   *
    region us-east-1
    log_group_name fluent-bit-cloudwatch
    log_stream_prefix from-fluent-bit-
    auto_create_group true 
EOF
    "parsers.conf" = <<EOF
[PARSER]
    Name maxlog
    Format json
    Time_Key @timestamp
    Time_Keep On
EOF
  }
}

# Policy for logging to CloudWatch
resource "aws_iam_policy" "FluentBitLoggingPolicy" {
  name   = "FluentBitLoggingPolicy"
  policy = file("${path.module}/policies/eks_fluentbit_logging_policy.json")
}

# Attach policy
resource "aws_iam_role_policy_attachment" "FluentBitLoggingPolicy" {
  policy_arn = aws_iam_policy.FluentBitLoggingPolicy.arn
  role       = aws_iam_role.fargate_pod_execution_role.name
}
