resource "aws_eks_fargate_profile" "main" {
  cluster_name           = aws_eks_cluster.main.name
  fargate_profile_name   = "${var.name}-${var.environment}-fp"
  pod_execution_role_arn = aws_iam_role.fargate_pod_execution_role.arn
  subnet_ids             = var.private_subnets[*].id

  selector {
    namespace = "default"
    labels = {
      "worker-group" = "fargate"
    }
  }

  selector {
    namespace = "${var.name}-${var.environment}"
    labels = {
      "worker-group" = "fargate"
    }
  }
}

resource "aws_iam_role_policy_attachment" "AmazonEKSFargatePodExecutionRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate_pod_execution_role.name
}

resource "aws_iam_role" "fargate_pod_execution_role" {
  name                  = "${var.name}-eks-fargate-pod-execution-role"
  force_detach_policies = true
  assume_role_policy    = file("${path.module}/policies/eks_fargate_pod_execution_role_policy.json")
}
