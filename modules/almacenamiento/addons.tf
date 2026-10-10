resource "aws_eks_pod_identity_association" "ebs_csi" {
  cluster_name         = var.cluster_name
  namespace            = "kube-system"
  service_account      = "ebs-csi-controller-sa"
  role_arn             = aws_iam_role.rol_ebs_csi.arn
  disable_session_tags = false

  depends_on = [
    aws_iam_role_policy_attachment.permisos_ebs_csi,
  ]
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name  = var.cluster_name
  addon_name    = "aws-ebs-csi-driver"
  addon_version = "v1.66.0-eksbuild.1"

  depends_on = [
    aws_eks_pod_identity_association.ebs_csi,
  ]
}
