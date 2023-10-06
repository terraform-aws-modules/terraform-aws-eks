################################################################################
# Launch template
################################################################################

output "launch_template_id" {
  description = "The ID of the launch template"
  value       = try(aws_launch_template.this[0].id, null)
}

output "launch_template_arn" {
  description = "The ARN of the launch template"
  value       = try(aws_launch_template.this[0].arn, null)
}

output "launch_template_latest_version" {
  description = "The latest version of the launch template"
  value       = try(aws_launch_template.this[0].latest_version, null)
}

output "launch_template_name" {
  description = "The name of the launch template"
  value       = try(aws_launch_template.this[0].name, null)
}

################################################################################
# autoscaling group
################################################################################

output "autoscaling_group_arn" {
  description = "The ARN for this autoscaling group"
  value       = try(aws_autoscaling_group.this[0].arn, null)
}

output "autoscaling_group_id" {
  description = "The autoscaling group id"
  value       = try(aws_autoscaling_group.this[0].id, null)
}

output "autoscaling_group_name" {
  description = "The autoscaling group name"
  value       = try(aws_autoscaling_group.this[0].name, null)
}

output "autoscaling_group_min_size" {
  description = "The minimum size of the autoscaling group"
  value       = try(aws_autoscaling_group.this[0].min_size, null)
}

output "autoscaling_group_max_size" {
  description = "The maximum size of the autoscaling group"
  value       = try(aws_autoscaling_group.this[0].max_size, null)
}

output "autoscaling_group_desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group"
  value       = try(aws_autoscaling_group.this[0].desired_capacity, null)
}

output "autoscaling_group_default_cooldown" {
  description = "Time between a scaling activity and the succeeding scaling activity"
  value       = try(aws_autoscaling_group.this[0].default_cooldown, null)
}

output "autoscaling_group_health_check_grace_period" {
  description = "Time after instance comes into service before checking health"
  value       = try(aws_autoscaling_group.this[0].health_check_grace_period, null)
}

output "autoscaling_group_health_check_type" {
  description = "EC2 or ELB. Controls how health checking is done"
  value       = try(aws_autoscaling_group.this[0].health_check_type, null)
}

output "autoscaling_group_availability_zones" {
  description = "The availability zones of the autoscaling group"
  value       = try(aws_autoscaling_group.this[0].availability_zones, null)
}

output "autoscaling_group_vpc_zone_identifier" {
  description = "The VPC zone identifier"
  value       = try(aws_autoscaling_group.this[0].vpc_zone_identifier, null)
}

################################################################################
# Autoscaling Group Schedule
################################################################################

output "autoscaling_group_schedule_arns" {
  description = "ARNs of autoscaling group schedules"
  value       = { for k, v in aws_autoscaling_schedule.this : k => v.arn }
}

################################################################################
# IAM Role
################################################################################

output "iam_role_name" {
  description = "The name of the IAM role"
  value       = try(aws_iam_role.this[0].name, null)
}

output "iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = try(aws_iam_role.this[0].arn, null)
}

output "iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = try(aws_iam_role.this[0].unique_id, null)
}

################################################################################
# IAM Instance Profile
################################################################################

output "iam_instance_profile_arn" {
  description = "ARN assigned by AWS to the instance profile"
  value       = try(aws_iam_instance_profile.this[0].arn, var.iam_instance_profile_arn)
}

output "iam_instance_profile_id" {
  description = "Instance profile's ID"
  value       = try(aws_iam_instance_profile.this[0].id, null)
}

output "iam_instance_profile_unique" {
  description = "Stable and unique string identifying the IAM instance profile"
  value       = try(aws_iam_instance_profile.this[0].unique_id, null)
}

################################################################################
# Additional
################################################################################

output "platform" {
  description = "Identifies if the OS platform is `bottlerocket`, `linux`, or `windows` based"
  value       = var.platform
}

output "image_id" {
  description = "ID of the image"
  value       = try(aws_launch_template.this[0].image_id, null)
}

output "user_data" {
  description = "Base64 encoded user data"
  value       = try(module.user_data.user_data, null)
}
