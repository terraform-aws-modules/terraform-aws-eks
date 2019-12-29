module "node_groups" {
  source                           = "./modules/node_groups"
  create_eks                       = var.create_eks
  cluster_name                     = var.cluster_name
  cluster_version                  = coalescelist(aws_eks_cluster.this[*].version, [""])[0]
  manage_worker_iam_resources      = var.manage_worker_iam_resources
  manage_worker_autoscaling_policy = var.manage_worker_autoscaling_policy
  attach_worker_autoscaling_policy = var.attach_worker_autoscaling_policy
  worker_autoscaling_policy_arn    = coalescelist(aws_iam_policy.worker_autoscaling[*].arn, [""])[0]
  workers_additional_policies      = var.workers_additional_policies
  workers_group_defaults           = local.workers_group_defaults
  role_name                        = var.node_groups_role_name
  permissions_boundary             = var.permissions_boundary
  iam_path                         = var.iam_path
  tags                             = var.tags
  node_groups_defaults             = var.node_groups_defaults
  node_groups                      = var.node_groups
}
