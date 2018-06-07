output "cluster_endpoint" {
  description = "Endpoint for EKS controlplane."
  value       = "${module.eks.cluster_endpoint}"
}

output "cluster_security_group_ids" {
  description = "."
  value       = "${module.eks.cluster_security_group_ids}"
}
