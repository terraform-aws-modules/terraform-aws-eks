output "user_data" {
  description = "Base64 encoded user data rendered for the provided inputs"
  value       = local.user_data_type_to_rendered
}
