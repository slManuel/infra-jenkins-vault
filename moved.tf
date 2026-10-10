# Direcciones históricas de raíz y del módulo intermedio.

moved {
  from = aws_iam_role.rol_cluster_eks
  to   = module.eks.aws_iam_role.rol_cluster_eks
}

moved {
  from = module.eks.aws_iam_role.rol_cluster_eks
  to   = module.identidad_base.aws_iam_role.rol_cluster_eks
}

moved {
  from = aws_iam_role_policy_attachment.permisos_cluster_eks
  to   = module.eks.aws_iam_role_policy_attachment.permisos_cluster_eks
}

moved {
  from = module.eks.aws_iam_role_policy_attachment.permisos_cluster_eks
  to   = module.identidad_base.aws_iam_role_policy_attachment.permisos_cluster_eks
}

moved {
  from = aws_iam_role.rol_nodos_eks
  to   = module.eks.aws_iam_role.rol_nodos_eks
}

moved {
  from = module.eks.aws_iam_role.rol_nodos_eks
  to   = module.identidad_base.aws_iam_role.rol_nodos_eks
}

moved {
  from = aws_iam_role_policy_attachment.permisos_nodos_eks
  to   = module.eks.aws_iam_role_policy_attachment.permisos_nodos_eks
}

moved {
  from = module.eks.aws_iam_role_policy_attachment.permisos_nodos_eks
  to   = module.identidad_base.aws_iam_role_policy_attachment.permisos_nodos_eks
}

moved {
  from = aws_iam_role_policy_attachment.descarga_imagenes_nodos
  to   = module.eks.aws_iam_role_policy_attachment.descarga_imagenes_nodos
}

moved {
  from = module.eks.aws_iam_role_policy_attachment.descarga_imagenes_nodos
  to   = module.identidad_base.aws_iam_role_policy_attachment.descarga_imagenes_nodos
}

moved {
  from = aws_eks_cluster.cluster_jenkins_vault
  to   = module.eks.aws_eks_cluster.cluster_jenkins_vault
}

moved {
  from = module.eks.aws_eks_cluster.cluster_jenkins_vault
  to   = module.cluster.aws_eks_cluster.cluster_jenkins_vault
}

moved {
  from = aws_eks_access_entry.administrador
  to   = module.eks.aws_eks_access_entry.administrador
}

moved {
  from = module.eks.aws_eks_access_entry.administrador
  to   = module.cluster.aws_eks_access_entry.administrador
}

moved {
  from = aws_eks_access_policy_association.administrador
  to   = module.eks.aws_eks_access_policy_association.administrador
}

moved {
  from = module.eks.aws_eks_access_policy_association.administrador
  to   = module.cluster.aws_eks_access_policy_association.administrador
}

moved {
  from = aws_iam_role.rol_vpc_cni
  to   = module.eks.aws_iam_role.rol_vpc_cni
}

moved {
  from = module.eks.aws_iam_role.rol_vpc_cni
  to   = module.red_pods.aws_iam_role.rol_vpc_cni
}

moved {
  from = aws_iam_role_policy_attachment.permisos_vpc_cni
  to   = module.eks.aws_iam_role_policy_attachment.permisos_vpc_cni
}

moved {
  from = module.eks.aws_iam_role_policy_attachment.permisos_vpc_cni
  to   = module.red_pods.aws_iam_role_policy_attachment.permisos_vpc_cni
}

moved {
  from = aws_eks_addon.pod_identity_agent
  to   = module.eks.aws_eks_addon.pod_identity_agent
}

moved {
  from = module.eks.aws_eks_addon.pod_identity_agent
  to   = module.red_pods.aws_eks_addon.pod_identity_agent
}

moved {
  from = aws_eks_pod_identity_association.vpc_cni
  to   = module.eks.aws_eks_pod_identity_association.vpc_cni
}

moved {
  from = module.eks.aws_eks_pod_identity_association.vpc_cni
  to   = module.red_pods.aws_eks_pod_identity_association.vpc_cni
}

moved {
  from = aws_eks_addon.vpc_cni
  to   = module.eks.aws_eks_addon.vpc_cni
}

moved {
  from = module.eks.aws_eks_addon.vpc_cni
  to   = module.red_pods.aws_eks_addon.vpc_cni
}

moved {
  from = aws_launch_template.herramientas["jenkins"]
  to   = module.eks.aws_launch_template.herramientas["jenkins"]
}

moved {
  from = module.eks.aws_launch_template.herramientas["jenkins"]
  to   = module.nodos.aws_launch_template.jenkins
}

moved {
  from = aws_eks_node_group.herramientas["jenkins"]
  to   = module.eks.aws_eks_node_group.herramientas["jenkins"]
}

moved {
  from = module.eks.aws_eks_node_group.herramientas["jenkins"]
  to   = module.nodos.aws_eks_node_group.jenkins
}

moved {
  from = aws_launch_template.herramientas["vault"]
  to   = module.eks.aws_launch_template.herramientas["vault"]
}

moved {
  from = module.eks.aws_launch_template.herramientas["vault"]
  to   = module.nodos.aws_launch_template.vault
}

moved {
  from = aws_eks_node_group.herramientas["vault"]
  to   = module.eks.aws_eks_node_group.herramientas["vault"]
}

moved {
  from = module.eks.aws_eks_node_group.herramientas["vault"]
  to   = module.nodos.aws_eks_node_group.vault
}

moved {
  from = aws_iam_role.rol_ebs_csi
  to   = module.eks.aws_iam_role.rol_ebs_csi
}

moved {
  from = module.eks.aws_iam_role.rol_ebs_csi
  to   = module.almacenamiento.aws_iam_role.rol_ebs_csi
}

moved {
  from = aws_iam_role_policy_attachment.permisos_ebs_csi
  to   = module.eks.aws_iam_role_policy_attachment.permisos_ebs_csi
}

moved {
  from = module.eks.aws_iam_role_policy_attachment.permisos_ebs_csi
  to   = module.almacenamiento.aws_iam_role_policy_attachment.permisos_ebs_csi
}

moved {
  from = aws_eks_pod_identity_association.ebs_csi
  to   = module.eks.aws_eks_pod_identity_association.ebs_csi
}

moved {
  from = module.eks.aws_eks_pod_identity_association.ebs_csi
  to   = module.almacenamiento.aws_eks_pod_identity_association.ebs_csi
}

moved {
  from = aws_eks_addon.ebs_csi
  to   = module.eks.aws_eks_addon.ebs_csi
}

moved {
  from = module.eks.aws_eks_addon.ebs_csi
  to   = module.almacenamiento.aws_eks_addon.ebs_csi
}

# Conserva recursos del módulo IAM anterior: cambio de dirección, no recreación.
moved {
  from = module.identidad_base
  to   = module.iam_roles
}
