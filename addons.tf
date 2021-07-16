module "addons" {
  source                  = "./modules/addons"
  cluster_name            = coalescelist(aws_eks_cluster.this[*].name, [""])[0]
  cluster_version         = var.cluster_version
  create_vpc_cni_addon    = var.create_vpc_cni_addon
  create_kube_proxy_addon = var.create_kube_proxy_addon
  create_coredns_addon    = var.create_coredns_addon
  cluster_oidc_issuer_url = flatten(concat(aws_eks_cluster.this[*].identity[*].oidc.0.issuer, [""]))[0]
  enable_irsa             = var.enable_irsa
  tags                    = var.addon_tags

  eks_depends_on = [
    aws_eks_cluster.this,
    kubernetes_config_map.aws_auth
  ]
}

