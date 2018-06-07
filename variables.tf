variable "cluster_ingress_cidrs" {
  description = "The CIDRs from which we can execute kubectl commands."
  type        = "list"
}

variable "cluster_name" {
  description = "Name of the EKS cluster."
}

variable "cluster_version" {
  description = "Kubernetes version to use for the cluster."
  default     = "1.10"
}

variable "subnets" {
  description = "A list of subnets to associate with the cluster's underlying instances."
  type        = "list"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "vpc_id" {
  description = "VPC id where the cluster and other resources will be deployed."
}

variable "workers_ami_id" {
  description = "AMI ID for the eks workers."
  default     = ""
}

variable "workers_asg_desired_capacity" {
  description = "description"
  default     = "1"
}

variable "workers_asg_max_size" {
  description = "description"
  default     = "3"
}

variable "workers_asg_min_size" {
  description = "description"
  default     = "1"
}

variable "workers_instance_type" {
  description = "Size of the workers instances."
  default     = "m4.large"
}

variable "workers_ami_mapping" {
  description = "Mapping from the region to the [EKS optimized AMI](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html)"
  type        = "map"

  default = {
    us-east-1 = "ami-dea4d5a1"
    us-west-2 = "ami-73a6e20b"
  }
}
