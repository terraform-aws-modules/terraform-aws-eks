output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.eks.cluster_security_group_id
}

# output "fargate_profile_arn" {
#   description = "Outputs from node groups"
#   value       = module.eks.fargate_profile_arn
# }
