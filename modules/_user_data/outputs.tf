output "user_data" {
  description = "Base64 encoded user data rendered for the provided inputs"
  value       = try(local.platform[var.platform].user_data, null)
}
