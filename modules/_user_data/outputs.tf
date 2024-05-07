output "user_data" {
  description = "Base64 encoded user data rendered for the provided inputs"
  value       = try(local.user_data_type_to_rendered[local.user_data_type].user_data, null)
}

output "platform" {
  description = "[DEPRECATED - Will be removed in `v21.0`] Identifies the OS platform as `bottlerocket`, `linux` (AL2), `al2023, or `windows`"
  value       = local.user_data_type
}
