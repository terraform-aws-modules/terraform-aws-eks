module "iam_assumable_role_with_oidc" {
  source      = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version     = "v4.1.0"
  create_role = true
  role_name   = join("_", [var.cluster_name, "vpc_cni"])
  # provider_url                  = replace(flatten(concat(aws_eks_cluster.this[*].identity[*].oidc.0.issuer, [""]))[0], "https://", "")
  provider_url                  = replace(var.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = ["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:aws-node"]
}
