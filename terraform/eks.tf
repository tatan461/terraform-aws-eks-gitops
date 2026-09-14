module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version

  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Configuración segura y estándar para los nodos administrados
  
 eks_managed_node_groups = {
  default = {
    min_size     = 1
    max_size     = 3
    desired_size = 1 # Reducimos a 1 temporalmente para ahorrar recursos

    instance_types = ["t3.small"] # Cambiado de t3.medium a t3.small para evitar el bloqueo
    capacity_type  = "ON_DEMAND"
  }
}

  enable_cluster_creator_admin_permissions = true
}