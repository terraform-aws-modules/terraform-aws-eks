output "cluster_endpoint" {
  description = "Endpoint for EKS controlplane."
  value       = "${module.eks.cluster_endpoint}"
}
