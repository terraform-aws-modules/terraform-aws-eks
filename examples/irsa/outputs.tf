output "aws_account_id" {
  description = "IAM AWS account id"
  value       = data.aws_caller_identity.current.account_id
}
