################################################################################
# Default (SSM) - Node IAM Role
################################################################################

# Node IAM Role
output "name" {
  description = "The name of the node IAM role"
  value       = module.eks_hybrid_node_role.name
}

output "arn" {
  description = "The Amazon Resource Name (ARN) specifying the node IAM role"
  value       = module.eks_hybrid_node_role.arn
}

output "unique_id" {
  description = "Stable and unique string identifying the node IAM role"
  value       = module.eks_hybrid_node_role.unique_id
}

# Intermedaite IAM Role
output "intermediate_role_name" {
  description = "The name of the node IAM role"
  value       = module.eks_hybrid_node_role.intermediate_role_name
}

output "intermediate_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the node IAM role"
  value       = module.eks_hybrid_node_role.intermediate_role_arn
}

output "intermediate_role_unique_id" {
  description = "Stable and unique string identifying the node IAM role"
  value       = module.eks_hybrid_node_role.intermediate_role_unique_id
}

################################################################################
# IAM Roles Anywhere - Node IAM Role
################################################################################

# Node IAM Role
output "ira_name" {
  description = "The name of the node IAM role"
  value       = module.ira_eks_hybrid_node_role.name
}

output "ira_arn" {
  description = "The Amazon Resource Name (ARN) specifying the node IAM role"
  value       = module.ira_eks_hybrid_node_role.arn
}

output "ira_unique_id" {
  description = "Stable and unique string identifying the node IAM role"
  value       = module.ira_eks_hybrid_node_role.unique_id
}

# Intermedaite IAM Role
output "ira_intermediate_role_name" {
  description = "The name of the node IAM role"
  value       = module.ira_eks_hybrid_node_role.intermediate_role_name
}

output "ira_intermediate_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the node IAM role"
  value       = module.ira_eks_hybrid_node_role.intermediate_role_arn
}

output "ira_intermediate_role_unique_id" {
  description = "Stable and unique string identifying the node IAM role"
  value       = module.ira_eks_hybrid_node_role.intermediate_role_unique_id
}
