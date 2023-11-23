data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_iam_role" "AmazonEKS_EBS_CSI_DriverRole" {
  name               = "AmazonEKS_EBS_CSI_DriverRole"
  description        = "Permissions required by the Kubernetes AWS EBS CSI Controller."
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
          "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
    }
  ]
}
ROLE
}

resource "aws_iam_role_policy_attachment" "aws_ebs_csi_driver_role_policy_attachement" {
  policy_arn = data.aws_iam_policy.ebs_csi_policy.arn
  role       = aws_iam_role.AmazonEKS_EBS_CSI_DriverRole.name
}

# Add Ons
resource "aws_eks_addon" "aws_ebs_csi_driver" {
  cluster_name             = aws_eks_cluster.main.name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.18.0-eksbuild.1"
  service_account_role_arn = aws_iam_role.AmazonEKS_EBS_CSI_DriverRole.arn
}
