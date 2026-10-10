output "cluster_name_for_storage" {
  description = "Nombre disponible tras ambos grupos de nodos."
  value       = aws_eks_node_group.jenkins.cluster_name
  depends_on  = [aws_eks_node_group.vault]
}

output "jenkins_node_group_name" {
  description = "Grupo Jenkins."
  value       = aws_eks_node_group.jenkins.node_group_name
}

output "vault_node_group_name" {
  description = "Grupo Vault."
  value       = aws_eks_node_group.vault.node_group_name
}
