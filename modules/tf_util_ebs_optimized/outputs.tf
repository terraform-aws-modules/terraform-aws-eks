output "answer" {
  description = "Returns true or false depending on if the instance type is able to be EBS optimized."
  value       = "${lookup(local.ebs_optimized_types, var.instance_type, false)}"
}
