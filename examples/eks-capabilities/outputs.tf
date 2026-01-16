################################################################################
# Capability - ACK
################################################################################

output "ack_arn" {
  description = "The ARN of the EKS Capability"
  value       = module.ack_eks_capability.arn
}

output "ack_version" {
  description = "The version of the EKS Capability"
  value       = module.ack_eks_capability.version
}

output "ack_argocd_server_url" {
  description = "URL of the Argo CD server"
  value       = module.ack_eks_capability.argocd_server_url
}

# IAM Role
output "ack_iam_role_name" {
  description = "The name of the IAM role"
  value       = module.ack_eks_capability.iam_role_name
}

output "ack_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = module.ack_eks_capability.iam_role_arn
}

output "ack_iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = module.ack_eks_capability.iam_role_unique_id
}

################################################################################
# Capability - ArgoCD
################################################################################

output "argocd_arn" {
  description = "The ARN of the EKS Capability"
  value       = module.argocd_eks_capability.arn
}

output "argocd_version" {
  description = "The version of the EKS Capability"
  value       = module.argocd_eks_capability.version
}

output "argocd_server_url" {
  description = "URL of the Argo CD server"
  value       = module.argocd_eks_capability.argocd_server_url
}

# IAM Role
output "argocd_iam_role_name" {
  description = "The name of the IAM role"
  value       = module.argocd_eks_capability.iam_role_name
}

output "argocd_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = module.argocd_eks_capability.iam_role_arn
}

output "argocd_iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = module.argocd_eks_capability.iam_role_unique_id
}

################################################################################
# Capability - KRO
################################################################################

output "kro_arn" {
  description = "The ARN of the EKS Capability"
  value       = module.kro_eks_capability.arn
}

output "kro_version" {
  description = "The version of the EKS Capability"
  value       = module.kro_eks_capability.version
}

output "kro_argocd_server_url" {
  description = "URL of the Argo CD server"
  value       = module.kro_eks_capability.argocd_server_url
}

# IAM Role
output "kro_iam_role_name" {
  description = "The name of the IAM role"
  value       = module.kro_eks_capability.iam_role_name
}

output "kro_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = module.kro_eks_capability.iam_role_arn
}

output "kro_iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = module.kro_eks_capability.iam_role_unique_id
}
