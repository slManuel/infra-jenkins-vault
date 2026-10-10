output "cluster_name" {
  description = "Nombre del clúster."
  value       = aws_eks_cluster.cluster_jenkins_vault.name
}

output "cluster_arn" {
  description = "ARN del clúster para confianza Pod Identity."
  value       = aws_eks_cluster.cluster_jenkins_vault.arn
}

output "kubernetes_version" {
  description = "Versión Kubernetes."
  value       = aws_eks_cluster.cluster_jenkins_vault.version
}
