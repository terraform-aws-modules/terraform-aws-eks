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

variable "workers_additional_sgs" {
  description = "A list of security group IDs which we want to set onto the worker nodes instances"
  type        = "list"
  default     = []
}

variable worker_node_allow_all_egress {
  description = "Specify whether you wish to allow worker node egress everwhere on all ports"
  default     = true
}

variable "cp_to_wn_from_port" {
  description = "The From port for the rules connecting our control plane to worker node"
  default     = 1025
}

variable "cp_to_wn_to_port" {
  description = "The to port for the rules connecting our control plane to worker node"
  default     = 65535
}
