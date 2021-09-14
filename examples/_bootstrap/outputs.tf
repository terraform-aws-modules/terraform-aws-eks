output "region" {
  description = "AWS region"
  value       = local.region
}

output "cluster_name" {
  description = "Name of EKS Cluster used in tags for subnets"
  value       = local.cluster_name
}

output "vpc" {
  description = "Complete output of VPC module"
  value       = module.vpc
}

output "barebone_eks" {
  description = "Complete output of Barebone EKS module"
  value       = module.barebone_eks
}
