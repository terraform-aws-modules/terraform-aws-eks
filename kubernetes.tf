provider "kubernetes" {
  host                   = concat(data.aws_eks_cluster.cluster[*].endpoint, [""])[0]
  cluster_ca_certificate = base64decode(concat(data.aws_eks_cluster.cluster[*].certificate_authority.0.data, [""])[0])
  token                  = concat(data.aws_eks_cluster_auth.cluster[*].token, [""])[0]
  load_config_file       = false
}
