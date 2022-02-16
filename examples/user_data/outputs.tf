# EKS managed node group - linux
output "eks_mng_linux_no_op" {
  description = "Base64 decoded user data rendered for the provided inputs"
  value       = base64decode(module.eks_mng_linux_no_op.user_data)
}

output "eks_mng_linux_additional" {
  description = "Base64 decoded user data rendered for the provided inputs"
  value       = base64decode(module.eks_mng_linux_additional.user_data)
}

output "eks_mng_linux_custom_ami" {
  description = "Base64 decoded user data rendered for the provided inputs"
  value       = base64decode(module.eks_mng_linux_custom_ami.user_data)
}

output "eks_mng_linux_custom_template" {
  description = "Base64 decoded user data rendered for the provided inputs"
  value       = base64decode(module.eks_mng_linux_custom_template.user_data)
}

# EKS managed node group - bottlerocket
output "eks_mng_bottlerocket_no_op" {
  description = "Base64 decoded user data rendered for the provided inputs"
  value       = base64decode(module.eks_mng_bottlerocket_no_op.user_data)
}

output "eks_mng_bottlerocket_additional" {
  description = "Base64 decoded user data rendered for the provided inputs"
  value       = base64decode(module.eks_mng_bottlerocket_additional.user_data)
}

output "eks_mng_bottlerocket_custom_ami" {
  description = "Base64 decoded user data rendered for the provided inputs"
  value       = base64decode(module.eks_mng_bottlerocket_custom_ami.user_data)
}

output "eks_mng_bottlerocket_custom_template" {
  description = "Base64 decoded user data rendered for the provided inputs"
  value       = base64decode(module.eks_mng_bottlerocket_custom_template.user_data)
}

# Self managed node group - linux
output "self_mng_linux_no_op" {
  description = "Base64 decoded user data rendered for the provided inputs"
  value       = base64decode(module.self_mng_linux_no_op.user_data)
}

output "self_mng_linux_bootstrap" {
  description = "Base64 decoded user data rendered for the provided inputs"
  value       = base64decode(module.self_mng_linux_bootstrap.user_data)
}

output "self_mng_linux_custom_template" {
  description = "Base64 decoded user data rendered for the provided inputs"
  value       = base64decode(module.self_mng_linux_custom_template.user_data)
}

# Self managed node group - bottlerocket
output "self_mng_bottlerocket_no_op" {
  description = "Base64 decoded user data rendered for the provided inputs"
  value       = base64decode(module.self_mng_bottlerocket_no_op.user_data)
}

output "self_mng_bottlerocket_bootstrap" {
  description = "Base64 decoded user data rendered for the provided inputs"
  value       = base64decode(module.self_mng_bottlerocket_bootstrap.user_data)
}

output "self_mng_bottlerocket_custom_template" {
  description = "Base64 decoded user data rendered for the provided inputs"
  value       = base64decode(module.self_mng_bottlerocket_custom_template.user_data)
}

# Self managed node group - windows
output "self_mng_windows_no_op" {
  description = "Base64 decoded user data rendered for the provided inputs"
  value       = base64decode(module.self_mng_windows_no_op.user_data)
}

output "self_mng_windows_bootstrap" {
  description = "Base64 decoded user data rendered for the provided inputs"
  value       = base64decode(module.self_mng_windows_bootstrap.user_data)
}

output "self_mng_windows_custom_template" {
  description = "Base64 decoded user data rendered for the provided inputs"
  value       = base64decode(module.self_mng_windows_custom_template.user_data)
}
