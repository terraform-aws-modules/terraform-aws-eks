data "aws_ecrpublic_authorization_token" "token" {
  region = "us-east-1"
}

module "karpenter" {
  # source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  # version = "21.10.1"
  source = "../../modules/karpenter"

  cluster_name = module.eks.cluster_name

  # Name needs to match role name passed to the EC2NodeClass
  node_iam_role_use_name_prefix   = false
  node_iam_role_name              = local.name
  create_pod_identity_association = true
  enable_inline_policy            = true

  # Used to attach additional IAM policies to the Karpenter node IAM role
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    CiliumPolicy                 = aws_iam_policy.aws_cilium_policy.arn
  }

  tags = local.tags

  depends_on = [module.eks]
}

################################################################################
# Karpenter Helm chart & manifests
################################################################################

resource "helm_release" "karpenter" {
  namespace           = "kube-system"
  name                = "karpenter"
  repository          = "oci://public.ecr.aws/karpenter"
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.token.password
  chart               = "karpenter"
  version             = "1.6.0"
  wait                = false

  values = [
    <<-EOT
    nodeSelector:
      karpenter.sh/controller: 'true'
    dnsPolicy: Default
    settings:
      clusterName: ${module.eks.cluster_name}
      clusterEndpoint: ${module.eks.cluster_endpoint}
      interruptionQueue: ${module.karpenter.queue_name}
      enableZonalShift: true
    webhook:
      enabled: false
    EOT
  ]

  # Karpenter controller runs on managed nodes — needs both
  depends_on = [
    module.eks_managed_node_group,
    module.karpenter,
    aws_eks_addon.coredns, # needs DNS to resolve ECR
  ]

}
