output "vpc_cni_id" {
  description = "The id of the Amazon VPC CNI addon"
  value       = aws_eks_addon.vpc_cni[0].id
}

output "coredns_id" {
  description = "The id of the CoreDns addon"
  value       = aws_eks_addon.coredns[0].id
}

output "kube_proxy_id" {
  description = "The id of the kube-proxy addon"
  value       = aws_eks_addon.kube_proxy[0].id
}
