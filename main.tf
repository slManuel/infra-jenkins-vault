module "iam_roles" {
  source    = "./modules/iam_roles"
  providers = { aws = aws }
}

module "cluster" {
  source                      = "./modules/cluster"
  providers                   = { aws = aws }
  cluster_role_arn            = module.iam_roles.cluster_role_arn
  private_subnet_ids          = data.terraform_remote_state.red_compartida.outputs.private_subnet_ids
  administrator_principal_arn = data.aws_iam_user.administrador_cluster.arn
}

module "red_pods" {
  source       = "./modules/red_pods"
  providers    = { aws = aws }
  cluster_name = module.cluster.cluster_name
  cluster_arn  = module.cluster.cluster_arn
}

module "nodos" {
  source                   = "./modules/nodos"
  providers                = { aws = aws }
  cluster_name             = module.red_pods.cluster_name_for_nodes
  kubernetes_version       = module.cluster.kubernetes_version
  node_role_arn            = module.iam_roles.node_role_arn
  private_subnet_ids_by_az = data.terraform_remote_state.red_compartida.outputs.private_subnet_ids_by_az
}

module "almacenamiento" {
  source       = "./modules/almacenamiento"
  providers    = { aws = aws }
  cluster_name = module.nodos.cluster_name_for_storage
  cluster_arn  = module.cluster.cluster_arn
  depends_on   = [module.red_pods]
}
