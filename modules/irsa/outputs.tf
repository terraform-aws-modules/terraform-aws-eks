################################################################################
# Kubernetes Namespace
################################################################################

output "namespace" {
  description = "The full map of attributes for the namespace created"
  value       = kubernetes_namespace_v1.this
}

################################################################################
# Kubernetes Service Account
################################################################################

output "service_account" {
  description = "The full map of attributes for the service account created"
  value       = kubernetes_service_account_v1.this
}

output "service_account_name" {
  description = "The full map of attributes for the service account created"
  value       = element(split("/", join("", kubernetes_service_account_v1.this[*].id)), 1)
  # Weird bug which won't let me do this:
  # value     = element(split(kubernetes_service_account_v1.this[*].id, "/"), 1)
}

################################################################################
# IAM Role
################################################################################

output "iam_role_name" {
  description = "The name of the IAM role"
  value       = try(aws_iam_role.this[0].name, "")
}

output "iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = try(aws_iam_role.this[0].arn, "")
}

output "iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = try(aws_iam_role.this[0].unique_id, "")
}
