# Hack to ensure ordering of resource creation. Do not create Fargate resources
# before other resources are ready. Removes race conditions.
data "null_data_source" "fargate" {
  count = var.create_eks ? 1 : 0

  inputs = {
    cluster_name = coalescelist(aws_eks_cluster.this[*].name, [""])[0]

    # Ensure these resources are created before "unlocking" the data source.
    # `depends_on` causes a refresh on every run so is useless here.
    # [Re]creating or removing these resources will trigger recreation of Fargate resources
    aws_auth        = coalescelist(kubernetes_config_map.aws_auth[*].id, [""])[0]
  }
}

module "fargate" {
  source                            = "./modules/fargate"
  cluster_name                      = coalescelist(data.null_data_source.fargate[*].outputs["cluster_name"], [""])[0]
  create_eks                        = var.create_eks
  create_fargate_pod_execution_role = var.create_fargate_pod_execution_role
  fargate_profiles                  = var.fargate_profiles
  subnets                           = var.subnets
  tags                              = var.tags
}
