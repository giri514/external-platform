resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "kube-system"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = var.private_subnets[*].id

  scaling_config {
    desired_size = 5
    max_size     = 9
    min_size     = 5
  }

  instance_types = ["t2.medium"]

  tags = {
    Name        = "${var.name}-${var.environment}-eks-node-group"
    Environment = var.environment
  }

  depends_on = [
    aws_iam_role_policy_attachment.nodegroup-AmazonEBSCSIDriver,
    aws_iam_role_policy_attachment.nodegroup-LoadBalancerAdditionalPolicy,
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_eks_node_group" "monitoring" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "monitoring"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = var.private_subnets[*].id

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 2
  }

  instance_types = ["t2.medium"]

  tags = {
    Name        = "${var.name}-${var.environment}-monitoring-node-group"
    Environment = var.environment
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_iam_role" "eks_node_group_role" {
  name                  = "${var.name}-eks-node-group-role"
  force_detach_policies = true
  assume_role_policy    = file("${path.module}/policies/eks_node_group_role_policy.json")
}

resource "aws_iam_policy" "eks_node_group_ebs_policy" {
  name   = "Amazon_EBS_CSI_Driver"
  policy = file("${path.module}/policies/eks_node_group_ebs_policy.json")
}

resource "aws_iam_policy" "eks_node_group_additional_policy" {
  name   = "Amazon_Load_Balancer_Additional_Policy"
  policy = file("${path.module}/policies/eks_node_group_load_balancer_policy.json")
}

resource "aws_iam_role_policy_attachment" "nodegroup-AmazonEBSCSIDriver" {
  policy_arn = aws_iam_policy.eks_node_group_ebs_policy.arn
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "nodegroup-LoadBalancerAdditionalPolicy" {
  policy_arn = aws_iam_policy.eks_node_group_additional_policy.arn
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group_role.name
}
