################################################################################
# Kubernetes Namespace
################################################################################

output "namespace" {
  description = "The full map of attributes for the namespace created"
  value       = module.irsa.namespace
}

################################################################################
# Kubernetes Service Account
################################################################################

output "service_account" {
  description = "The full map of attributes for the service account created"
  value       = module.irsa.service_account
}

output "service_account_name" {
  description = "The full map of attributes for the service account created"
  value       = module.irsa.service_account_name
}

################################################################################
# IAM Role
################################################################################

output "iam_role_name" {
  description = "The name of the IAM role"
  value       = module.irsa.iam_role_name
}

output "iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = module.irsa.iam_role_arn
}

output "iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = module.irsa.iam_role_unique_id
}
