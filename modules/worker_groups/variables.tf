variable "additional_userdata" {
  description = "Extra lines of userdata (bash) which are appended to the default userdata code."
  default     = ""
}

variable "aws_region" {
  description = "The AWS region where the cluster resides."
}

variable "certificate_authority" {
  description = "Base64 encoded certificate authority of the cluster."
}

variable "cluster_name" {
  description = "Name of the EKS cluster which is also used as a prefix in names of related resources."
}

variable "ebs_optimized_workers" {
  description = "If left at default of true, will use ebs optimization if available on the given instance type."
  default     = true
}

variable "endpoint" {
  description = "API endpoint of the cluster."
}

variable "iam_instance_profile" {
  description = "Worker IAM instance profile name."
}

variable "security_group_id" {
  description = "Worker security group ID."
}

variable "subnets" {
  description = "A list of subnets to associate with the cluster's underlying instances."
  type        = "list"
}

variable "tags" {
  description = "A map of tags to add to all resources."
  default     = {}
}

variable "workers_ami_id" {
  description = "AMI ID for the eks workers. If none is provided, Terraform will search for the latest version of their EKS optimized worker AMI."
  default     = ""
}

variable "worker_groups" {
  description = "A list of maps defining worker group configurations."
  type        = "list"

  default = [
    {
      name                 = "nodes"    # Name of the worker group.
      ami_id               = ""         # AMI ID for the eks workers. If none is provided, Terraform will search for the latest version of their EKS optimized worker AMI.
      asg_desired_capacity = "1"        # Desired worker capacity in the autoscaling group.
      asg_max_size         = "3"        # Maximum worker capacity in the autoscaling group.
      asg_min_size         = "1"        # Minimum worker capacity in the autoscaling group.
      instance_type        = "m4.large" # Size of the workers instances.
    },
  ]
}
