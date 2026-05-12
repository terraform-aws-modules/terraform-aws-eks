variable "cilium_version" {
  type    = string
  default = "1.18.0"
}

variable "cilium_helm_repo" {
  type    = string
  default = "https://helm.cilium.io"

}

# ─── STEP 1: Cilium IAM Policy (no cluster dependency) ───────────────────────
resource "aws_iam_policy" "aws_cilium_policy" {
  name        = "${local.name}-cilium-policy"
  description = "EKS Cilium policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:CreateNetworkInterface",
          "ec2:AttachNetworkInterface",
          "ec2:DetachNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:ModifyNetworkInterfaceAttribute",
          "ec2:AssignPrivateIpAddresses",
          "ec2:UnassignPrivateIpAddresses",
          "ec2:AssignIpv6Addresses",
          "ec2:UnassignIpv6Addresses",
          "ec2:CreateTags"
        ]
        Resource = "*"
      }
    ]
  })
}

# ─── STEP 2: Cilium — installed BEFORE nodes join ────────────────────────────
# Targets the control plane only. DaemonSet pods will be pending until
# managed nodes join, but the CNI config is already present on the node
# filesystem via the nodeInit bootstrap, so nodes become Ready immediately.
resource "helm_release" "cilium" {
  name       = "cilium"
  namespace  = "kube-system"
  chart      = "cilium"
  version    = var.cilium_version
  repository = var.cilium_helm_repo
  wait       = false # ← CRITICAL: must be false, no nodes yet to schedule on

  set = [
    {
      name  = "k8sServiceHost"
      value = trimprefix(module.eks.cluster_endpoint, "https://")
    }
  ]

  values = [file("${path.module}/cilium_values.yaml")]

  # Only depends on control plane, NOT on any node group
  depends_on = [module.eks]
}
