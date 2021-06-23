output "vpc_cni_arn" {
  description = "The arn of the Amazon VPC CNI addon"
  value       = length(aws_eks_addon.vpc_cni) > 0 ? aws_eks_addon.vpc_cni[0].arn : "Not deployed"
}

output "coredns_arn" {
  description = "The arn of the CoreDns addon"
  value       = length(aws_eks_addon.coredns) > 0 ? aws_eks_addon.coredns[0].arn : "Not deployed"
}

output "kube_proxy_arn" {
  description = "The arn of the kube-proxy addon"
  value       = length(aws_eks_addon.kube_proxy) > 0 ? aws_eks_addon.kube_proxy[0].arn : "Not deployed"
}
